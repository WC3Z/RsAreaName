-- TEMPORARY: prints where the player is whenever the game world or a region
-- (an instance) is built or updated, to find out what area names can be tied
-- to. Each print is repeated a game tick later, in case the player hasn't
-- moved to the new place yet when the event comes. Also prints whenever the
-- player walks into another town or kingdom (see world_areas).
local world_areas = require("src/game/world_areas")

local area_debug = {}

local subscription_name = "area-names-debug"

-- The event waiting to be printed again on the next game tick, if any.
---@type string?
local waiting_for_tick
-- The town and kingdom the player was last in.
---@type WorldTown?
local last_town
---@type WorldKingdom?
local last_kingdom

---@param tile CoordGrid?
---@return string
local function describe(tile)
    if not tile then
        return "nowhere"
    end
    return string.format("level %d, map square %d, %d, tile %d, %d (world tile %d, %d)",
        tile.level, tile.mapSquareX, tile.mapSquareZ, tile.localX, tile.localZ, tile.x, tile.z)
end

---@param label string
local function print_player(label)
    local player = Player.GetEntity()
    local tile = player and player.coordGrid
    print("[Area debug]   " .. label .. ": player at " .. describe(tile))
    if World.IsRegion() then
        print("[Area debug]   " .. label .. ": in a region, copied from "
            .. describe(tile and World.GetRegionSourceForCoordGrid(tile)))
    end
end

---@param event_name string
---@param details string?
local function on_event(event_name, details)
    print("[Area debug] " .. event_name .. (details and (": " .. details) or ""))
    print_player("now")
    waiting_for_tick = event_name
end

-- Where the player is in the game world: their tile, or in a region, the tile
-- it was copied from.
---@return CoordGrid?
local function world_tile()
    local player = Player.GetEntity()
    local tile = player and player.coordGrid
    if tile and World.IsRegion() then
        return World.GetRegionSourceForCoordGrid(tile) or tile
    end
    return tile
end

local function print_changed_place()
    local tile = world_tile()
    if not tile then
        return
    end
    local town = world_areas.town_at(tile.x, tile.z)
    local kingdom = world_areas.kingdom_at(tile.x, tile.z)
    if kingdom ~= last_kingdom then
        print("[Area debug] entered kingdom " .. (kingdom and kingdom.name or "(none)"))
        last_kingdom = kingdom
    end
    if town ~= last_town then
        local subtitle = town and town.subtitle and (" - " .. town.subtitle) or ""
        print("[Area debug] entered town " .. (town and town.name or "(none)") .. subtitle)
        last_town = town
    end
end

local function on_tick()
    if waiting_for_tick then
        print_player("a tick after " .. waiting_for_tick)
        waiting_for_tick = nil
    end
    print_changed_place()
end

---@param event WorldCreatedEventPayload|RegionCreatedEventPayload
---@return string
local function map_squares(event)
    return string.format("map squares %d, %d to %d, %d",
        event.mapSquareMinX, event.mapSquareMinZ, event.mapSquareMaxX, event.mapSquareMaxZ)
end

function area_debug.start()
    Event.WorldCreated.Subscribe(subscription_name, function(event)
        on_event("World created", map_squares(event))
    end)
    Event.WorldUpdated.Subscribe(subscription_name, function()
        on_event("World updated")
    end)
    Event.RegionCreated.Subscribe(subscription_name, function(event)
        on_event("Region created", string.format("%s, corner %s, %d x %d tiles", map_squares(event),
            describe(event.regionGridCorner), event.regionGridWidth, event.regionGridLength))
    end)
    Event.RegionUpdated.Subscribe(subscription_name, function()
        on_event("Region updated")
    end)
    Event.ServerLogic.Subscribe(subscription_name, on_tick)
end

function area_debug.stop()
    Event.WorldCreated.Unsubscribe(subscription_name)
    Event.WorldUpdated.Unsubscribe(subscription_name)
    Event.RegionCreated.Unsubscribe(subscription_name)
    Event.RegionUpdated.Unsubscribe(subscription_name)
    Event.ServerLogic.Unsubscribe(subscription_name)
    waiting_for_tick = nil
    last_town = nil
    last_kingdom = nil
end

return area_debug
