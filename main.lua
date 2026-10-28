local area_title = require("src/ui/area_title")
local content_view = require("src/interface/content_view")
local world_tracker = require("src/tracker/world_tracker")

area_title.start()
content_view.start()
world_tracker.start()

function PluginShutdown()
    world_tracker.stop()
    content_view.stop()
    area_title.stop()
end
