local area_title = require("src/ui/area_title")
local content_view = require("src/interface/content_view")
local world_tracker = require("src/tracker/world_tracker")
local world_areas = require("src/game/world_areas")
-- The mapping tools are only in dev builds; release builds leave out src/mapping.
local has_mapping_tools = pcall(require, "src/mapping/area_borders")
local area_borders = has_mapping_tools and require("src/mapping/area_borders") or nil
local corner_marker = has_mapping_tools and require("src/mapping/corner_marker") or nil

area_title.start()
content_view.start()
world_tracker.start()

function PluginShutdown()
    world_tracker.stop()
    if area_borders then
        area_borders.hide()
    end
    content_view.stop()
    area_title.stop()
end

-- What plugins that depend on this one get, like a local copy of Better World Map that
-- draws the areas on its map for debugging. The mapping tools are nil in release builds.
return {
    world_areas = world_areas,
    corner_marker = corner_marker,
    area_borders = area_borders,
}
