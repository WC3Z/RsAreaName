local area_title = require("src/ui/area_title")
local content_view = require("src/interface/content_view")
local world_tracker = require("src/tracker/world_tracker")
local area_borders = require("src/game/area_borders")
local corner_marker = require("src/game/corner_marker")
local world_areas = require("src/game/world_areas")
-- TEMPORARY
local instance_debug = require("src/game/instance_debug")

area_title.start()
content_view.start()
world_tracker.start()
instance_debug.start()

function PluginShutdown()
    world_tracker.stop()
    area_borders.hide()
    instance_debug.stop()
    content_view.stop()
    area_title.stop()
end

-- What plugins that depend on this one get, like a local copy of Better World Map that
-- draws the areas on its map for debugging.
return {
    world_areas = world_areas,
    corner_marker = corner_marker,
    area_borders = area_borders,
}
