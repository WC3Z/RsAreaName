local db = require("src/database/db")
local world_areas = require("src/game/world_areas")
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

---@type WorldInstance?
local current_instance = nil
---@type WorldPlace?
local current_place = nil
---@type WorldKingdom?
local current_kingdom = nil

-- Game ticks left before titles show, after logging in or a loading screen.
local ticks_until_titles = login_delay_ticks
-- Whether the game is being played, and not loading, reconnecting or in the
-- lobby. Titles wait until it is.
local in_game = true
-- Game ticks since the plugin started, and when each area's title was last shown.
local tick = 0
---@type table<WorldInstance|WorldPlace|WorldKingdom, integer>
local shown_at = {}
-- Whether the player got where they are by teleport (or portal), so its
-- title shows even if it was shown a moment ago.
local arrived_by_teleport = false
-- Where the player was on the last game tick, to tell teleports apart.
---@type integer?
local last_x = nil
---@type integer?
local last_z = nil

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

-- The known instance the player is in, if any. BOSS_INSTANCE_CURRENT_BOSS
-- keeps its value after leaving, so it's only used inside an instance.
---@return WorldInstance?
local function instance_now()
    if not World.IsRegion() then
        return nil
    end
    local instance_id = var.VarPlayer.BOSS_INSTANCE_CURRENT_BOSS.value
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
local function place_counts(place)
    return db.get_show_kind("places") and not db.is_area_hidden(place.name)
end

-- Whether the player wants titles for this kingdom. Unlike places, kingdoms
-- they don't are still tracked, since places use their names as subtitles.
---@param kingdom WorldKingdom
---@return boolean
local function kingdom_shown(kingdom)
    return db.get_show_kind("kingdoms") and not db.is_area_hidden(kingdom.name)
end

-- Shows an area's title, unless the player walked in and it was shown less
-- than the "Repeat titles after" setting ago, like when stepping out of a
-- place and straight back in. Arriving by teleport always shows it.
---@param area WorldInstance|WorldPlace|WorldKingdom
---@param subtitle string?
local function show(area, subtitle)
    local last_shown = shown_at[area]
    local repeat_ticks = db.get_repeat_minutes() * ticks_per_minute
    if not arrived_by_teleport and last_shown and tick - last_shown < repeat_ticks then
        return
    end
    shown_at[area] = tick
    area_title.show(area.name, subtitle, area.sprite)
end

-- Known instances come first, then places, then kingdoms. Leaving a place on
-- its own shows nothing.
local function on_tick()
    tick = tick + 1
    local player = Player.GetEntity()
    if (player == nil or not in_game or not World.IsAvailable()) then
        return
    end
    local x, z = world_tile(player)
    if (x == nil) then
        return
    end
    if (last_x ~= nil and (x - last_x) ^ 2 + (z - last_z) ^ 2 > teleport_distance ^ 2) then
        area_title.fade_away()
        ticks_until_titles = math.max(ticks_until_titles, db.get_teleport_delay_ticks())
        arrived_by_teleport = true
    end
    last_x, last_z = x, z
    if ticks_until_titles > 0 then
        ticks_until_titles = ticks_until_titles - 1
        return
    end

    local instance = instance_now()
    local place = world_areas.place_at(x, z, place_counts)
    if (place == nil and current_place ~= nil and place_counts(current_place)
        and world_areas.is_near_place(current_place, x, z, leave_margin)) then
        place = current_place
    end
    local kingdom = world_areas.kingdom_at(x, z)
    -- Still in the kingdom just left while near its edge. Only for outlines, as
    -- that's what distance_outside measures.
    if (kingdom ~= current_kingdom and current_kingdom ~= nil and current_kingdom.points
        and world_areas.distance_outside(current_kingdom, x, z) <= leave_margin) then
        kingdom = current_kingdom
    end

    if (instance ~= nil and current_instance ~= instance) then
        show(instance, instance.subtitle)
    elseif (instance == nil and place ~= nil and current_place ~= place) then
        -- The place's own subtitle, or the kingdom it's in.
        show(place, place.subtitle or (kingdom and kingdom.name))
    elseif (instance == nil and place == nil and kingdom ~= nil and current_kingdom ~= kingdom
        and kingdom_shown(kingdom)) then
        show(kingdom)
    end

    current_instance = instance
    current_place = place
    current_kingdom = kingdom
    arrived_by_teleport = false
end

-- Titles wait while the game isn't being played, like during a loading
-- screen, and a title that's showing goes away. Where the player is isn't
-- updated meanwhile, so the place they arrive at gets its title once the game
-- is back. Out of the game, to the lobby or the login screen: starts over, so
-- logging back in shows where the player is again.
---@param event GameStateChangedEventPayload
local function on_game_state_changed(event)
    if (event.newState == GameState.GAME) then
        in_game = true
        ticks_until_titles = math.max(ticks_until_titles, after_loading_delay_ticks)
    else
        in_game = false
        area_title.hide()
    end
    if (event.newState == GameState.LOBBY or event.newState == GameState.LOGINSCREEN) then
        current_instance = nil
        current_place = nil
        current_kingdom = nil
        shown_at = {}
        last_x, last_z = nil, nil
        ticks_until_titles = login_delay_ticks
    end
end

-- The world, or an instance, is built anew, with a loading screen: a title
-- that's showing fades away, and titles wait until it's over.
local function on_world_built()
    area_title.fade_away()
    ticks_until_titles = math.max(ticks_until_titles, db.get_teleport_delay_ticks())
    arrived_by_teleport = true
end

-- The title for where the player is now, as it shows when walking in: the
-- known instance, or the place (with its own subtitle, or its kingdom), or
-- the kingdom. Nothing outside every area.
---@return string? name
---@return string? subtitle
---@return string? sprite
function world_tracker.current_title()
    if current_instance then
        return current_instance.name, current_instance.subtitle, current_instance.sprite
    end
    if current_place then
        return current_place.name, current_place.subtitle or (current_kingdom and current_kingdom.name), current_place.sprite
    end
    if current_kingdom then
        return current_kingdom.name, nil, current_kingdom.sprite
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
end

return world_tracker
