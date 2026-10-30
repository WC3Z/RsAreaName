-- DEBUG: for tracing a place's outline in game. Each marked corner is where
-- the player stands, and the whole outline so far is printed as a line ready
-- to paste into world_areas.places.
local corner_marker = {}

---@type integer[][]
local corners = {}

local function print_outline()
    local points = {}
    for _, corner in ipairs(corners) do
        table.insert(points, string.format("{ %d, %d }", corner[1], corner[2]))
    end
    print(string.format('[Area Names] { name = "New place", points = { %s } },', table.concat(points, ", ")))
end

-- The corners marked so far, in order.
---@return integer[][]
function corner_marker.corners()
    return corners
end

---@param x integer
---@param z integer
function corner_marker.mark(x, z)
    table.insert(corners, { x, z })
    print(string.format("[Area Names] Corner %d at %d, %d", #corners, x, z))
    print_outline()
end

function corner_marker.undo()
    if #corners == 0 then
        return
    end
    table.remove(corners)
    print(string.format("[Area Names] Removed the last corner, %d left", #corners))
    print_outline()
end

function corner_marker.clear()
    corners = {}
    print("[Area Names] Corners cleared")
end

return corner_marker
