-- area_names_overlay.lua
-- LOCAL DEBUG ADDITION, not part of Better World Map: draws the Area Names plugin's areas
-- on whichever map is open, to check their borders, and lets outlines be traced by clicking.
-- Used by: main.lua, only when the Area Names dev plugin is loaded as an optional
-- dependency (plugin.json). Drawn only while Area Names' "Show area borders" setting is
-- on, and only the areas ticked on its "Map borders" tab, as drawing them all is slow.
--
-- Each area has its own colour, picked from its name, with its name written at its middle.
-- Kingdoms have thicker lines than towns and places. Corners marked in game with Area Names'
-- "Mark corner" are white; corners clicked on this map are magenta:
--   Ctrl+click        adds a corner where you click
--   Ctrl+Shift+click  removes the last corner
--   Ctrl+Alt+click    clears the corners
-- Each change logs the outline so far, ready to paste into Area Names' world_areas.towns.

local Map = require("map_math")
local Areas = require("map_areas")
local M = {}

-- Bright colours that stand out on the map and from each other.
local PALETTE = {
    0xFF5A5AFF,
    0xFFB13BFF,
    0xFFE74CFF,
    0x9BE564FF,
    0x3DDC97FF,
    0x46C6F0FF,
    0x5B8CFFFF,
    0xA77BFFFF,
    0xF16BD8FF,
    0xFF8C69FF,
    0xC7F464FF,
    0x7FE7FFFF,
}
local MARKED_IN_GAME = 0xFFFFFFFF
local CLICKED = 0xFF00FFFF
local KINGDOM_THICKNESS = 4
local THICKNESS = 2
local FONT = id.Font.MUSEO_SANS_13PT_BOLD
-- Lines are sampled about this many UI units apart, so they follow the map's moved
-- segments instead of cutting across them.
local SAMPLE_UNITS = 8

-- The same colour for an area every time, picked from its name.
local function colourOf(name)
    local hash = 0
    for i = 1, #name do
        hash = (hash * 31 + name:byte(i)) % 2147483647
    end
    return PALETTE[hash % #PALETTE + 1]
end

-- Calls into Area Names may fail if it was reloaded or disabled; nil then.
local function call(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end
end

-- The real world tile shown at a map position: the inverse of Areas.Project, on the ground
-- floor. nil off the map.
local function toWorld(areaID, mx, mz)
    for _, b in ipairs(Areas.Get(areaID).segments) do
        if
            b.level == 0
            and mx >= b.dx
            and mx < b.dx + b.w
            and mz >= b.dz
            and mz < b.dz + b.h
        then
            return math.floor(mx - b.dx + b.sx), math.floor(mz - b.dz + b.sz)
        end
    end
end

local function printOutline(corners)
    local points = {}
    for _, corner in ipairs(corners) do
        points[#points + 1] = string.format("{ %d, %d }", corner[1], corner[2])
    end
    print(string.format('[Area Names] { name = "New town", points = { %s } },', table.concat(points, ", ")))
end

-- main.create supplies the map layer; returns the overlay owner.
function M.new(parent)
    local self = { corners = {} }
    self.canvas = ui.Canvas.new(parent)
    self.canvas:SetSize(0, 0, 1, 1)
    self.canvas.clickthrough = true

    -- Draws a line through world-tile points, moved onto the open map by toMap. Points off
    -- that map break the line.
    local function polyline(points, colour, thickness, toMap, cx, cz, scale, w, h)
        local lastX, lastY
        for _, point in ipairs(points) do
            local mx, mz = toMap(point[1], point[2])
            if mx then
                local x, y = Map.project(mx, mz, cx, cz, scale, w, h)
                local onScreen = not (
                    (x < 0 and lastX and lastX < 0)
                    or (x > w and lastX and lastX > w)
                    or (y < 0 and lastY and lastY < 0)
                    or (y > h and lastY and lastY > h)
                )
                if lastX and onScreen then
                    self.canvas:AddLine(lastX, lastY, x, y, thickness, colour)
                end
                lastX, lastY = x, y
            else
                lastX, lastY = nil, nil
            end
        end
    end

    -- Writes the name at a world tile, if that's on the open map and on screen.
    local function label(text, x, z, colour, toMap, cx, cz, scale, w, h)
        local mx, mz = toMap(x, z)
        if not mx then
            return
        end
        local px, py = Map.project(mx, mz, cx, cz, scale, w, h)
        if px >= 0 and px < w and py >= 0 and py < h then
            self.canvas:AddText(math.floor(px), math.floor(py), text, FONT, colour)
        end
    end

    -- Points every step tiles along the lines between corners, closed back to the first.
    local function along(corners, step, closed, offset)
        local points = {}
        local count = #corners
        local last = closed and count or count - 1
        for i = 1, last do
            local from, to = corners[i], corners[i % count + 1]
            local length = math.max(math.abs(to[1] - from[1]), math.abs(to[2] - from[2]))
            local steps = math.max(1, math.ceil(length / step))
            for s = 0, steps - 1 do
                local t = s / steps
                points[#points + 1] = {
                    from[1] + offset + t * (to[1] - from[1]),
                    from[2] + offset + t * (to[2] - from[2]),
                }
            end
        end
        local final = closed and corners[1] or corners[count]
        if final then
            points[#points + 1] = { final[1] + offset, final[2] + offset }
        end
        return points
    end

    -- Rectangles are inclusive tiles, so their outline runs along the outer tile edges.
    local function rectangle(bounds, step)
        local x0, z0, x1, z1 = bounds[1], bounds[2], bounds[3] + 1, bounds[4] + 1
        return along({ { x0, z0 }, { x1, z0 }, { x1, z1 }, { x0, z1 } }, step, true, 0)
    end

    local function circle(town, step)
        local points = {}
        local steps = math.max(12, math.ceil(2 * math.pi * town.radius / step))
        for s = 0, steps do
            local angle = 2 * math.pi * s / steps
            points[#points + 1] = {
                town.at[1] + 0.5 + town.radius * math.cos(angle),
                town.at[2] + 0.5 + town.radius * math.sin(angle),
            }
        end
        return points
    end

    -- The middle of an outline's corners, for its name.
    local function middle(corners)
        local x, z = 0, 0
        for _, corner in ipairs(corners) do
            x, z = x + corner[1], z + corner[2]
        end
        return x / #corners, z / #corners
    end

    -- A kingdom or place: its outline, or each of its rectangles outlined and the name on
    -- the first.
    local function rectangles(area, thickness, step, toMap, cx, cz, scale, w, h)
        local colour = colourOf(area.name)
        if area.points then
            polyline(along(area.points, step, true, 0.5), colour, thickness, toMap, cx, cz, scale, w, h)
            local x, z = middle(area.points)
            label(area.name, x, z, colour, toMap, cx, cz, scale, w, h)
            return
        end
        for _, bounds in ipairs(area.bounds) do
            polyline(rectangle(bounds, step), colour, thickness, toMap, cx, cz, scale, w, h)
        end
        local first = area.bounds[1]
        if first then
            label(area.name, (first[1] + first[3]) / 2, (first[2] + first[4]) / 2, colour, toMap, cx, cz, scale, w, h)
        end
    end

    local function town(area, step, toMap, cx, cz, scale, w, h)
        local colour = colourOf(area.name)
        local points = area.points and along(area.points, step, true, 0.5) or circle(area, step)
        polyline(points, colour, THICKNESS, toMap, cx, cz, scale, w, h)
        local x, z
        if area.points then
            x, z = middle(area.points)
        else
            x, z = area.at[1], area.at[2]
        end
        label(area.name, x, z, colour, toMap, cx, cz, scale, w, h)
    end

    -- main's map click handler supplies the open map and the clicked map position, when Ctrl
    -- is held. Returns true when the click was used, so the map doesn't also pan.
    function self:Click(areaID, mx, mz)
        if Keyboard.IsAltDown() then
            self.corners = {}
            print("[Area Names] Map corners cleared")
            return true
        end
        if Keyboard.IsShiftDown() then
            table.remove(self.corners)
            print(string.format("[Area Names] Removed the last map corner, %d left", #self.corners))
            printOutline(self.corners)
            return true
        end
        local x, z = toWorld(areaID, mx, mz)
        if not x then
            print("[Area Names] That spot isn't part of this map")
            return true
        end
        self.corners[#self.corners + 1] = { x, z }
        print(string.format("[Area Names] Map corner %d at %d, %d", #self.corners, x, z))
        printOutline(self.corners)
        return true
    end

    -- main.draw supplies the Area Names export, the active area and viewport. Rebuilds only
    -- when the view, the setting or the corners change.
    -- What of Area Names' state the drawing depends on: the setting, which areas are
    -- ticked, and the corners. Shared by Draw and Changed.
    local function stateKey(areaNames)
        local borders = areaNames and areaNames.area_borders or {}
        local shown = areaNames ~= nil and call(borders.is_shown) == true
        local marked = shown and areaNames.corner_marker and call(areaNames.corner_marker.corners) or {}
        local lastMarked, lastClicked = marked[#marked], self.corners[#self.corners]
        local key = table.concat({
            tostring(shown),
            #marked,
            lastMarked and (lastMarked[1] .. "," .. lastMarked[2]) or "",
            tostring(call(borders.areas_shown_version)),
            #self.corners,
            lastClicked and (lastClicked[1] .. "," .. lastClicked[2]) or "",
        }, ":")
        return key, shown, borders, marked
    end

    -- main's logic loop asks every tick: whether Area Names' state changed since the last
    -- draw (like an area ticked on its "Map borders" tab), so the map draws again even though
    -- the view didn't move.
    function self:Changed(areaNames)
        return (stateKey(areaNames)) ~= self.lastState
    end

    function self:Draw(areaNames, areaID, cx, cz, scale, w, h)
        local state, shown, borders, marked = stateKey(areaNames)
        self.lastState = state
        local key = table.concat({ state, areaID, cx, cz, scale, w, h }, ":")
        if self.last == key then
            return
        end
        self.last = key
        self.canvas:Clear()
        if not shown then
            return
        end
        local areas = areaNames.world_areas or {}
        -- Through each map's segments, like the player marker, since maps (the surface too)
        -- move parts of the world. Area Names' areas have no floor, so the ground floor is used.
        local function toMap(x, z)
            return Areas.Project(areaID, x, z, 0)
        end
        local function isShown(name)
            return call(borders.is_area_shown, name) == true
        end
        local step = math.max(1, math.floor(SAMPLE_UNITS / scale))
        for _, kingdom in ipairs(areas.kingdoms or {}) do
            if isShown(kingdom.name) then
                rectangles(kingdom, KINGDOM_THICKNESS, step, toMap, cx, cz, scale, w, h)
            end
        end
        for _, place in ipairs(areas.places or {}) do
            if isShown(place.name) then
                rectangles(place, THICKNESS, step, toMap, cx, cz, scale, w, h)
            end
        end
        for _, area in ipairs(areas.towns or {}) do
            if isShown(area.name) then
                town(area, step, toMap, cx, cz, scale, w, h)
            end
        end
        for _, corners in ipairs({ { marked, MARKED_IN_GAME }, { self.corners, CLICKED } }) do
            local list, colour = corners[1], corners[2]
            if #list >= 2 then
                polyline(along(list, step, #list >= 3, 0.5), colour, THICKNESS, toMap, cx, cz, scale, w, h)
            end
        end
    end

    return self
end
return M
