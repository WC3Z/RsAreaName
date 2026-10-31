-- A separate, movable window with all the settings, opened from the plugin's
-- page. Its tabs are Text (how titles look and how long they show), Sound, and
-- Areas (which kinds of area, and which kingdoms, places, boss fights and
-- heists get titles).
local db = require("src/database/db")
local area_title = require("src/ui/area_title")
local world_areas = require("src/game/world_areas")
local settings_controls = require("src/interface/settings_controls")
local area_checkboxes = require("src/interface/area_checkboxes")

local settings_window = {}

local window
local tabs

-- The main game screen, so the window can be moved anywhere over the game.
local function game_area()
    return ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__GAME_AREA)
end

---@param seconds number
---@return string
local function seconds_text(seconds)
    return string.format("%.1f s", seconds)
end

---@param page table
local function add_text_page(page)
    settings_controls.add_font_choices(page)
    settings_controls.add_choice(page, "Colour", area_title.colours, db.get_colour(), db.set_colour)
    page:AddText("Custom colour")
    page:AddColourPicker({
        value = db.get_custom_colour(),
        tooltip = "The colour used when Colour is Custom",
        onChange = function (_, colour)
            db.set_custom_colour(colour)
        end
    })
    settings_controls.add_toggle(page, "Show shields",
        "Shows an area's lodestone shield above its name, if it has one",
        db.get_show_shield(), db.set_show_shield)

    settings_controls.add_slider(page, {
        label = function (percent) return string.format("Height on screen: %d%%", percent) end,
        min = 5,
        max = 80,
        step = 5,
        value = db.get_title_height(),
        tooltip = "How far down the screen the title is",
        on_change = db.set_title_height,
    })
    local fade_in, stay, fade_out = db.get_title_timing()
    settings_controls.add_slider(page, {
        label = function (seconds) return "Fade in: " .. seconds_text(seconds) end,
        min = 0,
        max = 3,
        step = 0.5,
        value = fade_in,
        tooltip = "How long the title takes to appear",
        on_change = db.set_fade_in,
    })
    settings_controls.add_slider(page, {
        label = function (seconds) return "Stays: " .. seconds_text(seconds) end,
        min = 0.5,
        max = 10,
        step = 0.5,
        value = stay,
        tooltip = "How long the title stays before fading out",
        on_change = db.set_stay,
    })
    settings_controls.add_slider(page, {
        label = function (seconds) return "Fade out: " .. seconds_text(seconds) end,
        min = 0,
        max = 3,
        step = 0.5,
        value = fade_out,
        tooltip = "How long the title takes to disappear",
        on_change = db.set_fade_out,
    })
    settings_controls.add_preview_button(page)
end

---@param page table
local function add_sound_page(page)
    settings_controls.add_sound_toggle(page)
    settings_controls.add_choice(page, "Sound", area_title.sounds, db.get_sound(), function (sound)
        db.set_sound(sound)
        -- So the sound can be heard while picking one.
        area_title.play_sound()
    end)
    page:AddSimpleButton("Play", function ()
        area_title.play_sound()
    end)
end

-- The kinds of area that can be turned off as a whole, as on the Areas tab.
local area_kinds = {
    { kind = "kingdoms", text = "Kingdoms", tooltip = "Titles when you cross into a kingdom" },
    { kind = "places", text = "Places", tooltip = "Titles for towns, islands, dungeons and other places" },
    { kind = "bosses", text = "Boss fights", tooltip = "Titles for boss fights, some only once the fight starts" },
    { kind = "heists", text = "Heists", tooltip = "Titles for heists" },
}

-- The boss fights and the heists, for their checkboxes, keyed by instance id.
-- A boss whose name another boss has too, like Nex, also gets its subtitle.
---@return { name: string, key: string }[] bosses
---@return { name: string, key: string }[] heists
local function instance_lists()
    local name_counts = {}
    for _, instance in pairs(world_areas.instances) do
        name_counts[instance.name] = (name_counts[instance.name] or 0) + 1
    end
    local bosses, heists = {}, {}
    for instance_id, instance in pairs(world_areas.instances) do
        local name = instance.name
        if name_counts[name] > 1 and instance.subtitle then
            name = name .. ", " .. instance.subtitle
        end
        table.insert(instance.heist and heists or bosses, { name = name, key = tostring(instance_id) })
    end
    return bosses, heists
end

---@param page table
local function add_areas_page(page)
    page:AddTitle("Show titles for")
    local items = {}
    for _, area_kind in ipairs(area_kinds) do
        table.insert(items, {
            text = area_kind.text,
            value = area_kind.kind,
            selected = db.get_show_kind(area_kind.kind),
            tooltip = area_kind.tooltip,
        })
    end
    page:AddCheckboxButton(items, {
        onChange = function (_, _, kind, selected)
            db.set_show_kind(kind, selected)
        end
    })

    settings_controls.add_slider(page, {
        label = function (minutes) return string.format("Repeat titles after: %d min", minutes) end,
        min = 0,
        max = 5,
        step = 1,
        value = db.get_repeat_minutes(),
        tooltip = "How long before an area's title shows again when you walk back in. 0 shows it every time. Arriving by teleport always shows it",
        on_change = db.set_repeat_minutes,
    })

    local function is_shown(name)
        return not db.is_area_hidden(name)
    end
    local function set_shown(names, shown)
        for _, name in ipairs(names) do
            db.set_area_hidden(name, not shown)
        end
    end
    area_checkboxes.add(page, "Kingdoms", world_areas.kingdoms, is_shown, set_shown)
    area_checkboxes.add(page, "Places", world_areas.places, is_shown, set_shown)

    local bosses, heists = instance_lists()
    local function is_instance_shown(key)
        return not db.is_instance_hidden(tonumber(key))
    end
    local function set_instances_shown(keys, shown)
        for _, key in ipairs(keys) do
            db.set_instance_hidden(tonumber(key), not shown)
        end
    end
    area_checkboxes.add(page, "Boss fights", bosses, is_instance_shown, set_instances_shown)
    area_checkboxes.add(page, "Heists", heists, is_instance_shown, set_instances_shown)
end

-- prettyui only re-measures the window's own scroll area when the window is
-- resized, not the tabs', so their scrollbars would keep the old size. There
-- is no resize callback, so the window's SetSize (which resizing calls) is
-- wrapped. Selecting the open tab again makes prettyui re-measure every tab.
local function refresh_tabs_on_resize()
    local set_size = window.SetSize
    window.SetSize = function (self, width, height)
        set_size(self, width, height)
        if tabs then
            tabs:SetActive(tabs:GetActiveIndex(), false)
        end
    end
end

-- Opens the window, or brings back a fresh one if it's already open, so it
-- shows settings changed on the plugin's page meanwhile.
function settings_window.open()
    settings_window.close()
    window = prettyui.Window.new(game_area(), {
        title = "Area Names settings",
        width = 320,
        height = 440,
        resizable = true,
        minWidth = 240,
        minHeight = 200,
        -- The tabs scroll instead.
        scrollable = false,
        destroyOnClose = true,
        onClose = function ()
            window = nil
            tabs = nil
        end,
    })
    refresh_tabs_on_resize()
    -- prettyui tabs keep a fixed height, so they're made to fill the window,
    -- and each tab scrolls on its own.
    tabs = window:AddTabs({ "Text", "Sound", "Areas" }, { y = 0, height = 0, heightAnchor = 1.0 })
    add_text_page(tabs:GetPage(1))
    add_sound_page(tabs:GetPage(2))
    add_areas_page(tabs:GetPage(3))
end

function settings_window.close()
    if window then
        window:Destroy()
        window = nil
        tabs = nil
    end
end

return settings_window
