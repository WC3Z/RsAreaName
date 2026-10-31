-- DEBUG: the "Map borders" tab, with the mapping tools: drawing the areas'
-- borders, and marking corners to trace an outline. Only in dev builds.
local world_areas = require("src/game/world_areas")
local world_tracker = require("src/tracker/world_tracker")
local area_borders = require("src/mapping/area_borders")
local corner_marker = require("src/mapping/corner_marker")
local area_checkboxes = require("src/interface/area_checkboxes")

local borders_page = {}

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

    -- For tracing a place's outline: stand on each corner in turn. The
    -- outline so far is printed, ready to paste into world_areas.places.
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

    for _, list in ipairs({ { "Kingdoms", world_areas.kingdoms }, { "Places", world_areas.places } }) do
        area_checkboxes.add(page, list[1], list[2], area_borders.is_area_shown, area_borders.set_areas_shown)
    end
end

return borders_page
