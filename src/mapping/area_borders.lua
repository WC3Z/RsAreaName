-- DEBUG: draws the borders of the areas in world_areas on the ground around
-- the player, to check them against the game world. Only the areas picked on
-- the "Map borders" tab are drawn, as drawing them all is slow. Each area has its own
-- colour, picked from its name (the same as on the Better World Map debug
-- overlay), and the corners marked with corner_marker are white. Only in the
-- main world, as an instance's tiles aren't where the areas are.
local world_areas = require("src/game/world_areas")
local corner_marker = require("src/mapping/corner_marker")

local area_borders = {}

local server_logic_subscription = "area_names_borders_server_logic"
local draw_subscription = "area_names_borders_draw"

-- Fine units in a tile, the unit positions in the game world are drawn in.
local fine_per_tile = 512
-- How many tiles around the player the borders are drawn, about as far as
-- the game has the ground loaded.
local view_distance = 48
-- How many tiles apart the points along a town's circle are.
local circle_step = 2
-- How far above the ground the lines are, in fine units, so they don't sink
-- into it.
local height_above_ground = 30
local line_width = 4.0
-- Colours are 0xRRGGBBAA. Bright ones that stand out from the ground and
-- from each other.
local palette = {
    0xFF5A5AFF, 0xFFB13BFF, 0xFFE74CFF, 0x9BE564FF, 0x3DDC97FF, 0x46C6F0FF,
    0x5B8CFFFF, 0xA77BFFFF, 0xF16BD8FF, 0xFF8C69FF, 0xC7F464FF, 0x7FE7FFFF,
}
local marked_colour = 0xFFFFFFFF

local shown = false

-- The same colour for an area every time, picked from its name.
---@param name string
---@return integer
local function colour_of(name)
    local hash = 0
    for i = 1, #name do
        hash = (hash * 31 + name:byte(i)) % 2147483647
    end
    return palette[hash % #palette + 1]
end

-- The names of the areas whose borders are drawn. None at first.
---@type table<string, boolean>
local areas_shown = {}
-- Goes up whenever areas_shown changes, so the Better World Map debug overlay
-- knows to draw again.
local areas_shown_version = 0

-- The lines to draw, worked out once a game tick: each a colour and its
-- points, in fine units.
---@type { colour: integer, positions: Vector3[] }[]
local lines = {}

-- Builds the lines through the given points, in tiles. Points too far from
-- the player, or where the ground isn't loaded, break the line in two.
---@param colour integer
---@param points number[][] { x, z } in tiles
---@param player_tile CoordGrid
---@param fine_offset Vector3 What to add to a tile times fine_per_tile to get its position in fine units
local function add_lines(colour, points, player_tile, fine_offset)
    local positions = {}
    local function finish_line()
        if #positions >= 2 then
            table.insert(lines, { colour = colour, positions = positions })
        end
        positions = {}
    end

    for _, point in ipairs(points) do
        local x, z = point[1], point[2]
        local near = math.abs(x - player_tile.x) <= view_distance and math.abs(z - player_tile.z) <= view_distance
        local fine_x = x * fine_per_tile + fine_offset.x
        local fine_z = z * fine_per_tile + fine_offset.z
        local height = near and World.GetGroundHeight(player_tile.level, fine_x, fine_z) or -1
        if height == -1 then
            finish_line()
        else
            table.insert(positions, Vector3.new(fine_x, height + height_above_ground, fine_z))
        end
    end
    finish_line()
end

-- The points around a rectangle's outer edge, one a tile.
---@param bounds integer[] { min x, min z, max x, max z }, both ends included
---@return number[][]
local function rectangle_points(bounds)
    local min_x, min_z, max_x, max_z = bounds[1], bounds[2], bounds[3] + 1, bounds[4] + 1
    local points = {}
    for x = min_x, max_x do table.insert(points, { x, min_z }) end
    for z = min_z + 1, max_z do table.insert(points, { max_x, z }) end
    for x = max_x - 1, min_x, -1 do table.insert(points, { x, max_z }) end
    for z = max_z - 1, min_z, -1 do table.insert(points, { min_x, z }) end
    return points
end

-- The points along lines between the given corners, one a tile, through
-- the middle of the corner tiles.
---@param corners integer[][]
---@param closed boolean Whether the last corner joins back to the first
---@return number[][]
local function outline_points(corners, closed)
    local points = {}
    local function add_line(from, to)
        local steps = math.max(1, math.ceil(math.max(math.abs(to[1] - from[1]), math.abs(to[2] - from[2]))))
        for step = 0, steps - 1 do
            local along = step / steps
            table.insert(points, { from[1] + 0.5 + along * (to[1] - from[1]), from[2] + 0.5 + along * (to[2] - from[2]) })
        end
    end
    for index = 2, #corners do
        add_line(corners[index - 1], corners[index])
    end
    if closed then
        add_line(corners[#corners], corners[1])
        table.insert(points, { corners[1][1] + 0.5, corners[1][2] + 0.5 })
    elseif #corners > 0 then
        table.insert(points, { corners[#corners][1] + 0.5, corners[#corners][2] + 0.5 })
    end
    return points
end

---@param town WorldTown
---@return number[][]
local function circle_points(town)
    local centre_x, centre_z = town.at[1] + 0.5, town.at[2] + 0.5
    local steps = math.max(8, math.ceil(2 * math.pi * town.radius / circle_step))
    local points = {}
    for step = 0, steps do
        local angle = 2 * math.pi * step / steps
        table.insert(points, { centre_x + town.radius * math.cos(angle), centre_z + town.radius * math.sin(angle) })
    end
    return points
end

---@param area WorldKingdom|WorldPlace
---@param colour integer
---@param player_tile CoordGrid
---@param fine_offset Vector3
local function add_rectangles(area, colour, player_tile, fine_offset)
    if area.points then
        add_lines(colour, outline_points(area.points, true), player_tile, fine_offset)
        return
    end
    for _, bounds in ipairs(area.bounds) do
        local far = bounds[1] - view_distance > player_tile.x or bounds[3] + view_distance < player_tile.x
            or bounds[2] - view_distance > player_tile.z or bounds[4] + view_distance < player_tile.z
        if not far then
            add_lines(colour, rectangle_points(bounds), player_tile, fine_offset)
        end
    end
end

local function on_tick()
    lines = {}
    local player = Player.GetEntity()
    local player_tile = player and player.coordGrid
    if player_tile == nil or World.IsRegion() or not World.IsAvailable() then
        return
    end
    -- Where the player's tile is in fine units, compared to its tile number,
    -- in case fine units don't start at tile 0.
    local player_fine = player_tile:ToCoordFine(false).position
    local fine_offset = Vector3.new(player_fine.x - player_tile.x * fine_per_tile, 0,
        player_fine.z - player_tile.z * fine_per_tile)

    for _, kingdom in ipairs(world_areas.kingdoms) do
        if areas_shown[kingdom.name] then
            add_rectangles(kingdom, colour_of(kingdom.name), player_tile, fine_offset)
        end
    end
    for _, place in ipairs(world_areas.places) do
        if areas_shown[place.name] then
            add_rectangles(place, colour_of(place.name), player_tile, fine_offset)
        end
    end
    for _, town in ipairs(world_areas.towns) do
        -- How far the player is from the town's edge, inside or out.
        local distance = areas_shown[town.name]
            and math.abs(world_areas.distance_outside(town, player_tile.x, player_tile.z))
        if distance and distance <= view_distance * math.sqrt(2) then
            local points = town.points and outline_points(town.points, true) or circle_points(town)
            add_lines(colour_of(town.name), points, player_tile, fine_offset)
        end
    end
    local marked = corner_marker.corners()
    if #marked >= 2 then
        add_lines(marked_colour, outline_points(marked, #marked >= 3), player_tile, fine_offset)
    end
end

local function on_draw()
    for _, line in ipairs(lines) do
        ShapeList.DrawLine({
            positions = line.positions,
            colour = line.colour,
            lineWidth = line_width,
            ignoreDepth = true,
        })
    end
end

-- Whether the area with this name has its border drawn.
---@param name string
---@return boolean
function area_borders.is_area_shown(name)
    return areas_shown[name] == true
end

-- Draws, or stops drawing, the borders of the areas with these names.
---@param names string[]
---@param shown_or_not boolean
function area_borders.set_areas_shown(names, shown_or_not)
    for _, name in ipairs(names) do
        areas_shown[name] = shown_or_not or nil
    end
    areas_shown_version = areas_shown_version + 1
end

-- A number that changes whenever which areas are drawn changes.
---@return integer
function area_borders.areas_shown_version()
    return areas_shown_version
end

---@return boolean
function area_borders.is_shown()
    return shown
end

function area_borders.show()
    if shown then
        return
    end
    shown = true
    Event.ServerLogic.Subscribe(server_logic_subscription, on_tick)
    Event.Draw.Subscribe(draw_subscription, on_draw)
end

function area_borders.hide()
    shown = false
    Event.ServerLogic.Unsubscribe(server_logic_subscription)
    Event.Draw.Unsubscribe(draw_subscription)
    lines = {}
end

return area_borders
