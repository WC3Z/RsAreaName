-- The plugin's page: the most used settings, and a button opening the settings
-- window with the rest. Dev builds also have a tab with the mapping tools
-- (src/mapping), which release builds leave out.
local settings_controls = require("src/interface/settings_controls")
local settings_window = require("src/interface/settings_window")
-- nil in release builds, which don't have src/mapping.
local has_mapping_tools = pcall(require, "src/mapping/borders_page")
local borders_page = has_mapping_tools and require("src/mapping/borders_page") or nil

local content_view = {}

local subscription_name = "area-names-content"

local view

---@param page table
local function add_settings_page(page)
    settings_controls.add_font_choices(page)
    settings_controls.add_sound_toggle(page)
    settings_controls.add_preview_button(page)
    page:AddSimpleButton("Open settings", function ()
        settings_window.open()
    end)
end

function content_view.start()
    Event.ContentLayerReady.Subscribe(subscription_name, function (event)
        -- This runs every time the page is opened, so throw away the old one first.
        if view then view:Destroy() end

        local parent = event.component
        view = prettyui.SimpleView.new(parent, {
            width = parent.width,
            height = parent.height,
            -- With tabs, each tab scrolls on its own instead.
            scrollable = borders_page == nil
        })

        if not borders_page then
            add_settings_page(view)
            return
        end
        local tabs = view:AddTabs({ "Settings", "Map borders" }, { height = parent.height })
        add_settings_page(tabs:GetPage(1))
        borders_page.add(tabs:GetPage(2))
    end)
end

function content_view.stop()
    Event.ContentLayerReady.Unsubscribe(subscription_name)
    settings_window.close()
    if view then
        view:Destroy()
        view = nil
    end
end

return content_view
