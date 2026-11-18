local db = require("src/database/db")
local world_areas = require("src/game/world_areas")
local area_choice = require("src/tracker/area_choice")
local area_title = require("src/ui/area_title")

local world_tracker = {}

local server_logic_subscription = "world_names_server_logic"
local game_state_subscription = "world_names_game_state"
local world_built_subscription = "world_names_world_built"

-- Game ticks (0.6 seconds each) to wait after logging in before showing where
-- the player is, so the title doesn't play during the loading screen.
local login_delay_ticks = 4
-- Game ticks to wait after a loading screen before titles show again.
local after_loading_delay_ticks = 2
-- A move of more than this many tiles in one game tick is a teleport (walking
-- and running move at most 2). After one, and after the world is built anew,
-- titles wait the "Delay after teleport" setting, as a teleport's loading
-- screen comes after the player has moved and doesn't change the game state.
local teleport_distance = 10
-- Game ticks in a minute, for the "Repeat titles after" setting.
local ticks_per_minute = 100
-- How many tiles outside a place or kingdom the player has to go to have left
-- it, so walking along its edge doesn't show titles back and forth.
local leave_margin = 5
-- Instances are copied from the game world in blocks this many tiles wide.
local copied_block_size = 8
-- How many tiles away from where a boss's health bar was last seen the player
-- has to go to have left its fight, for bosses outside instances.
local leave_fight_distance = 32

-- Everything the tracker keeps between game ticks. Made anew when the player
-- leaves the game (see on_game_state_changed) and when the plugin stops.
---@class TrackerState
---@field where Whereabouts The areas the player was in on the last game tick that titles could show.
---@field bar_instance_id integer? The boss last known by its health bar's name. It stays until the player leaves, as the bar goes away when the fight ends, and when the player dies.
---@field bar_x integer? The player's tile when the bar was last seen.
---@field bar_z integer?
---@field ticks_until_titles integer Game ticks left before titles show, after logging in or a loading screen.
---@field in_game boolean Whether the game is being played, and not loading, reconnecting or in the lobby. Titles wait until it is.
---@field tick integer Game ticks since the state was made.
---@field shown_at table<WorldInstance|WorldPlace|WorldKingdom, integer> The tick each area's title was last shown at.
---@field arrived_by_teleport boolean Whether the player got where they are by teleport (or portal), so its title shows even if it was shown a moment ago.
---@field last_x integer? Where the player was on the last game tick, to tell teleports apart.
---@field last_z integer?

---@return TrackerState
local function new_state()
    return {
        where = {},
        bar_instance_id = nil,
        bar_x = nil,
        bar_z = nil,
        ticks_until_titles = login_delay_ticks,
        in_game = true,
        tick = 0,
        shown_at = {},
        arrived_by_teleport = false,
        last_x = nil,
        last_z = nil,
    }
end

local state = new_state()

-- Where the player is in the game world: their tile, or in an instance, the
-- tile it was copied from. That's the same every time, wherever the game puts
-- the instance's copy.
---@param player PlayerEntity
---@return integer? x
---@return integer? z
local function world_tile(player)
    local tile = player.coordGrid
    if tile == nil then
        return nil
    end
    local source = World.IsRegion() and World.GetRegionSourceForCoordGrid(tile)
    if not source then
        return tile.x, tile.z
    end
    -- Instances are copied in blocks of 8 by 8 tiles, and the source is only
    -- the block's corner, so the player's place inside the block is added
    -- back. That's off if the block was copied turned, but still inside it.
    return source.x - source.x % copied_block_size + tile.x % copied_block_size,
        source.z - source.z % copied_block_size + tile.z % copied_block_size
end

-- Keeps track of the boss known by its health bar's name: remembers it while
-- the bar shows, and forgets it once the player has left its fight. Leaving
-- an instance rebuilds the world, which forgets it (see on_world_built);
-- outside instances, like at the Chaos Elemental, walking away does.
---@param x integer
---@param z integer
---@return integer? # The boss's instance id, if the player is still at its fight.
local function update_bar_boss(x, z)
    local bar_id = world_areas.instance_id_with_bar_name(var.VarClient.ACTIVITY_PROGRESS_BAR_ACTIVE_NAME.value)
    if bar_id then
        state.bar_instance_id, state.bar_x, state.bar_z = bar_id, x, z
    elseif state.bar_instance_id and not World.IsRegion()
        and (x - state.bar_x) ^ 2 + (z - state.bar_z) ^ 2 > leave_fight_distance ^ 2 then
        state.bar_instance_id = nil
    end
    return state.bar_instance_id
end

-- The known instance or boss fight the player is in, if any: by
-- BOSS_INSTANCE_CURRENT_BOSS, or else by the boss's health bar, for bosses
-- that don't set it or aren't in an instance. The var keeps its value after
-- leaving, so it's only used inside an instance.
---@param x integer
---@param z integer
---@return WorldInstance?
local function instance_now(x, z)
    local instance_id = World.IsRegion() and var.VarPlayer.BOSS_INSTANCE_CURRENT_BOSS.value or nil
    -- Checked every tick, even when the var is known, so the bar's boss is
    -- kept up to date for when the var goes back to 0.
    local bar_id = update_bar_boss(x, z)
    if world_areas.instance_with_id(instance_id) == nil then
        instance_id = bar_id
    end
    local instance = world_areas.instance_with_id(instance_id)
    if instance and (not db.get_show_kind(instance.heist and "heists" or "bosses")
        or db.is_instance_hidden(instance_id)) then
        return nil
    end
    return instance
end

-- Whether the player wants titles for this place. Places they don't are left
-- out of the lookup, so a bigger place around one shows instead.
---@param place WorldPlace
---@return boolean
local function is_place_wanted(place)
    return db.get_show_kind("places") and not db.is_area_hidden(place.name)
end

-- Whether the player wants titles for this kingdom. Unlike places, kingdoms
-- they don't are still tracked, since places use their names as subtitles.
---@param kingdom WorldKingdom
---@return boolean
local function is_kingdom_wanted(kingdom)
    return db.get_show_kind("kingdoms") and not db.is_area_hidden(kingdom.name)
end

-- Shows an area's title, unless the player walked in and it was shown less
-- than the "Repeat titles after" setting ago, like when stepping out of a
-- place and straight back in. Arriving by teleport always shows it.
---@param area WorldInstance|WorldPlace|WorldKingdom
---@param subtitle string?
local function show(area, subtitle)
    local last_shown = state.shown_at[area]
    local repeat_ticks = db.get_repeat_minutes() * ticks_per_minute
    if not state.arrived_by_teleport and last_shown and state.tick - last_shown < repeat_ticks then
        return
    end
    state.shown_at[area] = state.tick
    area_title.show(area.name, subtitle, area.sprite)
end

-- The areas the player is in at this tile. A place or kingdom just left
-- still counts while the player is near its edge (see leave_margin).
---@param x integer
---@param z integer
---@return Whereabouts
local function whereabouts(x, z)
    local before = state.where
    local place = world_areas.place_at(x, z, is_place_wanted)
    if (place == nil and before.place ~= nil and is_place_wanted(before.place)
        and world_areas.is_near_place(before.place, x, z, leave_margin)) then
        place = before.place
    end
    local kingdom = world_areas.kingdom_at(x, z)
    if (kingdom ~= before.kingdom and before.kingdom ~= nil
        and world_areas.distance_outside(before.kingdom, x, z) <= leave_margin) then
        kingdom = before.kingdom
    end
    return { instance = instance_now(x, z), place = place, kingdom = kingdom }
end

-- Runs every game tick: shows the title of an area the player has come into
-- (see area_choice for which).
local function on_tick()
    state.tick = state.tick + 1
    local player = Player.GetEntity()
    if (player == nil or not state.in_game or not World.IsAvailable()) then
        return
    end
    local x, z = world_tile(player)
    if (x == nil) then
        return
    end
    if (state.last_x ~= nil and (x - state.last_x) ^ 2 + (z - state.last_z) ^ 2 > teleport_distance ^ 2) then
        area_title.fade_away()
        state.ticks_until_titles = math.max(state.ticks_until_titles, db.get_teleport_delay_ticks())
        state.arrived_by_teleport = true
    end
    state.last_x, state.last_z = x, z
    if state.ticks_until_titles > 0 then
        state.ticks_until_titles = state.ticks_until_titles - 1
        return
    end

    local where = whereabouts(x, z)
    local area, subtitle = area_choice.newly_entered(where, state.where, is_kingdom_wanted)
    if area then
        show(area, subtitle)
    end
    state.where = where
    state.arrived_by_teleport = false
end

-- Titles wait while the game isn't being played, like during a loading
-- screen, and a title that's showing goes away. Where the player is isn't
-- updated meanwhile, so the place they arrive at gets its title once the game
-- is back. Out of the game, to the lobby or the login screen: starts over, so
-- logging back in shows where the player is again.
---@param event GameStateChangedEventPayload
local function on_game_state_changed(event)
    if (event.newState == GameState.GAME) then
        state.in_game = true
        state.ticks_until_titles = math.max(state.ticks_until_titles, after_loading_delay_ticks)
    else
        state.in_game = false
        area_title.hide()
    end
    if (event.newState == GameState.LOBBY or event.newState == GameState.LOGINSCREEN) then
        state = new_state()
        state.in_game = false
    end
end

-- The world, or an instance, is built anew, with a loading screen: a title
-- that's showing fades away, and titles wait until it's over. A boss known by
-- its health bar is forgotten, as this may be another instance.
local function on_world_built()
    state.bar_instance_id = nil
    area_title.fade_away()
    state.ticks_until_titles = math.max(state.ticks_until_titles, db.get_teleport_delay_ticks())
    state.arrived_by_teleport = true
end

-- The title for where the player is now, as it shows when walking in (see
-- area_choice.title_of). Nothing outside every area.
---@return string? name
---@return string? subtitle
---@return string? sprite
function world_tracker.current_title()
    return area_choice.title_of(state.where)
end

-- The boss fight the player is in, by name, or nil when they aren't in one
-- (heists don't count).
---@return string?
function world_tracker.current_boss()
    local instance = state.where.instance
    if instance and not instance.heist then
        return instance.name
    end
    return nil
end

-- The player's world tile (in an instance, the one it was copied from), or
-- nil when there's no player.
---@return integer? x
---@return integer? z
function world_tracker.player_tile()
    local player = Player.GetEntity()
    if player == nil then
        return nil
    end
    return world_tile(player)
end

function world_tracker.start()
    Event.ServerLogic.Subscribe(server_logic_subscription, on_tick)
    Event.GameStateChanged.Subscribe(game_state_subscription, on_game_state_changed)
    Event.WorldCreated.Subscribe(world_built_subscription, on_world_built)
    Event.RegionCreated.Subscribe(world_built_subscription, on_world_built)
end

function world_tracker.stop()
    Event.ServerLogic.Unsubscribe(server_logic_subscription)
    Event.GameStateChanged.Unsubscribe(game_state_subscription)
    Event.WorldCreated.Unsubscribe(world_built_subscription)
    Event.RegionCreated.Unsubscribe(world_built_subscription)
    state = new_state()
end

return world_tracker
