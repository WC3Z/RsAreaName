-- The named areas in the game world: places (towns, islands, dungeons, worlds
-- of their own like War's Retreat), each an outline or a circle around its
-- middle; kingdoms, each an outline; and instances known by their id. All
-- positions are world tiles (CoordGrid.x and CoordGrid.z); a map square is 64
-- of them.
--
-- The areas themselves are in src/game/data; this file finds the one for where
-- the player is.
local world_areas = {}

---@class WorldPlace
---@field name      string
---@field subtitle? string      Shown under the name; without one, the kingdom it's in is
---@field sprite?   string      A sprite shown above the name, as its name in id.Sprite
---@field points?   integer[][] Its outline: the corners in order, each { world tile x, world tile z }. Places without one are a circle
---@field at?       integer[]   { world tile x, world tile z } of the circle's middle
---@field radius?   integer     The circle's radius, in tiles

---@class WorldKingdom
---@field name    string
---@field sprite? string      A sprite shown above the name, as its name in id.Sprite
---@field points  integer[][] Its outline, like a place's

---@class WorldInstance
---@field name      string
---@field subtitle? string
---@field sprite?   string  A sprite shown above the name, as its name in id.Sprite
---@field heist?    boolean A heist rather than a boss fight
---@field bar_names? string[] Other names the boss health bar may show, like the bosses' own names in a fight against two

---@type table<integer, WorldInstance>
world_areas.instances = require("src/game/data/instances")
---@type WorldPlace[]
world_areas.places = require("src/game/data/places")
---@type WorldKingdom[]
world_areas.kingdoms = require("src/game/data/kingdoms")

-- How far the tile is from the line between two corners, in tiles.
---@param x    number
---@param z    number
---@param from integer[]
---@param to   integer[]
---@return number
local function distance_to_line(x, z, from, to)
    local line_x, line_z = to[1] - from[1], to[2] - from[2]
    local length_squared = line_x ^ 2 + line_z ^ 2
    -- How far along the line the nearest point is, from 0 at `from` to 1 at `to`.
    local along = 0
    if length_squared > 0 then
        along = math.max(0, math.min(1, ((x - from[1]) * line_x + (z - from[2]) * line_z) / length_squared))
    end
    return math.sqrt((x - from[1] - along * line_x) ^ 2 + (z - from[2] - along * line_z) ^ 2)
end

-- Whether the tile is inside the outline: a line from it going +x crosses the
-- outline an odd number of times.
---@param points integer[][]
---@param x      number
---@param z      number
---@return boolean
local function inside_outline(points, x, z)
    local inside_it = false
    local previous = points[#points]
    for _, point in ipairs(points) do
        if (point[2] > z) ~= (previous[2] > z) then
            local crossing_x = point[1] + (z - point[2]) * (previous[1] - point[1]) / (previous[2] - point[2])
            if x < crossing_x then
                inside_it = not inside_it
            end
        end
        previous = point
    end
    return inside_it
end

-- How far the tile is outside the area (a place or a kingdom), in tiles; 0 or
-- less is inside it. Tiles on the outline count as inside.
---@param area WorldPlace | WorldKingdom
---@param x    integer
---@param z    integer
---@return number
function world_areas.distance_outside(area, x, z)
    if area.points then
        local nearest = math.huge
        local previous = area.points[#area.points]
        for _, point in ipairs(area.points) do
            nearest = math.min(nearest, distance_to_line(x, z, previous, point))
            previous = point
        end
        return inside_outline(area.points, x, z) and -nearest or nearest
    end
    return math.sqrt((x - area.at[1]) ^ 2 + (z - area.at[2]) ^ 2) - area.radius
end

-- How much ground each place covers, in square tiles, worked out when first
-- needed.
---@type table<WorldPlace, number>
local place_areas = setmetatable({}, { __mode = "k" })

---@param place WorldPlace
---@return number
local function area_of(place)
    if place_areas[place] then
        return place_areas[place]
    end
    local area
    if place.points then
        -- The shoelace formula.
        local twice_area = 0
        local previous = place.points[#place.points]
        for _, point in ipairs(place.points) do
            twice_area = twice_area + previous[1] * point[2] - point[1] * previous[2]
            previous = point
        end
        area = math.abs(twice_area) / 2
    else
        area = math.pi * place.radius ^ 2
    end
    place_areas[place] = area
    return area
end

-- The place the tile is in. Where places overlap, the smallest wins. nil
-- outside every place. Places `is_included` says no to are left out, so a
-- bigger place around them wins instead.
---@param x            integer
---@param z            integer
---@param is_included? fun(place: WorldPlace): boolean
---@return WorldPlace?
function world_areas.place_at(x, z, is_included)
    local smallest
    for _, place in ipairs(world_areas.places) do
        if world_areas.distance_outside(place, x, z) <= 0 and (not smallest or area_of(place) < area_of(smallest))
            and (not is_included or is_included(place)) then
            smallest = place
        end
    end
    return smallest
end

-- Whether the tile is in the place, or at most `margin` tiles outside it.
---@param place  WorldPlace
---@param x      integer
---@param z      integer
---@param margin number     In tiles
---@return boolean
function world_areas.is_near_place(place, x, z, margin)
    return world_areas.distance_outside(place, x, z) <= margin
end

-- The kingdom the tile is in: the first in the list whose outline it's in.
-- nil outside every kingdom.
---@param x integer
---@param z integer
---@return WorldKingdom?
function world_areas.kingdom_at(x, z)
    for _, kingdom in ipairs(world_areas.kingdoms) do
        if world_areas.distance_outside(kingdom, x, z) <= 0 then
            return kingdom
        end
    end
    return nil
end

-- The instance with the given BOSS_INSTANCE_CURRENT_BOSS value, if it's known.
---@param instance_id integer?
---@return WorldInstance?
function world_areas.instance_with_id(instance_id)
    return instance_id and world_areas.instances[instance_id]
end

-- A bar name as it's looked up: lowercase, without a leading "the", so "Gate
-- of Elidinis" finds The Gate of Elidinis.
---@param bar_name string
---@return string
local function bar_name_key(bar_name)
    return (string.lower(bar_name):gsub("^the ", ""))
end

-- Instance ids by the names their boss's health bar may show. Where two
-- share one, like the two Nex fights, the lowest id wins.
---@type table<string, integer>
local instance_ids_by_bar_name = {}
for instance_id, instance in pairs(world_areas.instances) do
    local bar_names = { instance.name }
    if instance.subtitle then
        table.insert(bar_names, instance.name .. " " .. instance.subtitle)
        table.insert(bar_names, instance.name .. ", " .. instance.subtitle)
    end
    for _, bar_name in ipairs(instance.bar_names or {}) do
        table.insert(bar_names, bar_name)
    end
    for _, bar_name in ipairs(bar_names) do
        local key = bar_name_key(bar_name)
        local other_id = instance_ids_by_bar_name[key]
        if other_id == nil or instance_id < other_id then
            instance_ids_by_bar_name[key] = instance_id
        end
    end
end

-- The id of the instance whose boss health bar has this name, if it's known.
---@param bar_name string?
---@return integer?
function world_areas.instance_id_with_bar_name(bar_name)
    if bar_name == nil or bar_name == "" then
        return nil
    end
    return instance_ids_by_bar_name[bar_name_key(bar_name)]
end

return world_areas
