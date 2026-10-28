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
-- Game ticks to wait after the world is built anew, like after a teleport,
-- whose loading screen doesn't change the game state.
local after_world_built_delay_ticks = 4
-- A move of more than this many tiles in one game tick is a teleport (walking
-- and running move at most 2), and titles wait this many game ticks after one,
-- as its loading screen comes after the player has moved.
local teleport_distance = 10
local after_teleport_delay_ticks = 4
-- Game ticks in a minute, for the "Repeat titles after" setting.
local ticks_per_minute = 100
-- How far outside a town's radius the player has to go to have left it, so
-- walking along its edge doesn't show it again and again.
local leave_town_scale = 1.2

---@type WorldPlace?
local current_place = nil
---@type WorldKingdom?
local current_kingdom = nil
---@type WorldTown?
local current_town = nil

-- Game ticks left before titles show, after logging in or a loading screen.
local ticks_until_titles = login_delay_ticks
-- Whether the game is being played, and not loading, reconnecting or in the
-- lobby. Titles wait until it is.
local in_game = true
-- Game ticks since the plugin started, and when each area's title was last shown.
local tick = 0
---@type table<WorldPlace|WorldTown|WorldKingdom, integer>
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
---@return CoordGrid?
local function world_tile(player)
    local tile = player.coordGrid
    if tile and World.IsRegion() then
        return World.GetRegionSourceForCoordGrid(tile) or tile
    end
    return tile
end

-- Shows an area's title, unless the player walked in and it was shown less
-- than the "Repeat titles after" setting ago, like when stepping out of a
-- town and straight back in. Arriving by teleport always shows it.
---@param area WorldPlace|WorldTown|WorldKingdom
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

-- Places come first, then towns, then kingdoms. Leaving a town on its own
-- shows nothing.
local function on_tick()
    tick = tick + 1
    local player = Player.GetEntity()
    if (player == nil or not in_game or not World.IsAvailable()) then
        return
    end
    local tile = world_tile(player)
    if (tile == nil) then
        return
    end
    if (last_x ~= nil and (tile.x - last_x) ^ 2 + (tile.z - last_z) ^ 2 > teleport_distance ^ 2) then
        area_title.hide()
        ticks_until_titles = math.max(ticks_until_titles, after_teleport_delay_ticks)
        arrived_by_teleport = true
    end
    last_x, last_z = tile.x, tile.z
    if ticks_until_titles > 0 then
        ticks_until_titles = ticks_until_titles - 1
        return
    end

    local place = world_areas.place_at(tile.x, tile.z)
    local town = world_areas.town_at(tile.x, tile.z)
    if (town == nil and current_town ~= nil
        and world_areas.is_near_town(current_town, tile.x, tile.z, leave_town_scale)) then
        town = current_town
    end
    local kingdom = world_areas.kingdom_at(tile.x, tile.z)

    if (place ~= nil and current_place ~= place) then
        show(place, place.subtitle)
    elseif (place == nil and town ~= nil and current_town ~= town) then
        -- The town's own subtitle, or the kingdom it's in.
        show(town, town.subtitle or (kingdom and kingdom.name))
    elseif (place == nil and kingdom ~= nil and current_kingdom ~= kingdom) then
        show(kingdom)
    end

    current_place = place
    current_kingdom = kingdom
    current_town = town
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
        current_place = nil
        current_kingdom = nil
        current_town = nil
        shown_at = {}
        last_x, last_z = nil, nil
        ticks_until_titles = login_delay_ticks
    end
end

-- The world, or an instance, is built anew, with a loading screen: a title
-- that's showing goes away, and titles wait until it's over.
local function on_world_built()
    area_title.hide()
    ticks_until_titles = math.max(ticks_until_titles, after_world_built_delay_ticks)
    arrived_by_teleport = true
end

-- The title for where the player is now, as it shows when walking in: the
-- place, or the town (with its own subtitle, or its kingdom), or the
-- kingdom. Nothing outside every area.
---@return string? name
---@return string? subtitle
---@return string? sprite
function world_tracker.current_title()
    if current_place then
        return current_place.name, current_place.subtitle, current_place.sprite
    end
    if current_town then
        return current_town.name, current_town.subtitle or (current_kingdom and current_kingdom.name), current_town.sprite
    end
    if current_kingdom then
        return current_kingdom.name, nil, current_kingdom.sprite
    end
    return nil
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
