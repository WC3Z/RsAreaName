-- DEBUG: the "Map borders" tab, with the mapping tools: drawing the areas'
-- borders, and marking corners to trace an outline. Only in dev builds.
local world_areas = require("src/game/world_areas")
local world_tracker = require("src/tracker/world_tracker")
local area_borders = require("src/mapping/area_borders")
local corner_marker = require("src/mapping/corner_marker")

local borders_page = {}

-- A heading, "All" and "None" buttons, and a checkbox for each area, to pick
-- which areas have their borders drawn. The areas are listed alphabetically,
-- ignoring a leading "The", not in world_areas' order, so they're easy to find.
---@param page table
---@param heading string
---@param areas { name: string }[]
local function add_area_checkboxes(page, heading, areas)
    local names = {}
    for _, area in ipairs(areas) do
        table.insert(names, area.name)
    end
    -- "The Wilderness" goes under W, where you'd look for it.
    local function sort_key(name)
        return name:lower():gsub("^the ", "")
    end
    table.sort(names, function (a, b) return sort_key(a) < sort_key(b) end)
    local items = {}
    for _, name in ipairs(names) do
        table.insert(items, { text = name, value = name, selected = area_borders.is_area_shown(name) })
    end

    page:AddText(heading)
    local checkboxes
    local function set_all(shown)
        area_borders.set_areas_shown(names, shown)
        for _, name in ipairs(names) do
            checkboxes:SetSelected(name, shown, false)
        end
    end
    page:AddSimpleButton("All " .. heading:lower(), function () set_all(true) end)
    page:AddSimpleButton("No " .. heading:lower(), function () set_all(false) end)
    checkboxes = page:AddCheckboxButton(items, {
        onChange = function (_, _, name, selected)
            area_borders.set_areas_shown({ name }, selected)
        end
    })
end

---@param page table
function borders_page.add(page)
    local borders_checkbox = page:AddCheckboxButton({
        {
            text = "Show area borders",
            value = "showBorders",
            selected = area_borders.is_shown(),
            tooltip = "Draws the borders of the areas ticked below on the ground around you, and on Better World Map if it's set up for it, each in its own colour. Not saved"
        }
    },
        {
            onChange = function (_, _, _, selected)
                if selected then
                    area_borders.show()
                else
                    area_borders.hide()
                end
            end
        })

    -- For tracing a town's outline: stand on each corner in turn. The
    -- outline so far is printed, ready to paste into world_areas.towns.
    page:AddSimpleButton("Mark corner", function ()
        local x, z = world_tracker.player_tile()
        if x == nil then
            return
        end
        corner_marker.mark(x, z)
        -- So the outline can be seen while tracing it.
        if not area_borders.is_shown() then
            area_borders.show()
            borders_checkbox:SetSelected("showBorders", true, false)
        end
    end)
    page:AddSimpleButton("Undo corner", corner_marker.undo)
    page:AddSimpleButton("Clear corners", corner_marker.clear)

    add_area_checkboxes(page, "Kingdoms", world_areas.kingdoms)
    add_area_checkboxes(page, "Places", world_areas.places)
    add_area_checkboxes(page, "Towns", world_areas.towns)
end

return borders_page
