-- The setting controls the plugin's page and the settings window share.
local db = require("src/database/db")
local area_title = require("src/ui/area_title")
local world_tracker = require("src/tracker/world_tracker")

local settings_controls = {}

-- How many entries an open dropdown shows before it scrolls, so a long list
-- like the sounds fits on small screens.
local dropdown_entries_shown = 6

-- A setting's choices, as entries for a combo box. The game's combo boxes
-- only take whole numbers as entry ids, so each entry's id is its choice's
-- place in the list, not the choice's own id.
---@param choices { id: string, label: string }[]
---@return { id: integer, label: string }[]
local function entries(choices)
    local result = {}
    for index, choice in ipairs(choices) do
        table.insert(result, { id = index, label = choice.label })
    end
    return result
end

-- Where the choice with the given id is in the list, or 1 if it isn't there.
---@param choices { id: string }[]
---@param choice_id string
---@return integer
local function index_of(choices, choice_id)
    for index, choice in ipairs(choices) do
        if choice.id == choice_id then
            return index
        end
    end
    return 1
end

-- A label with a combo box under it, for a setting with a few choices.
---@param page table The prettyui page to add it to
---@param label string
---@param choices { id: string, label: string }[]
---@param selected string
---@param on_change fun(choice_id: string)
---@return table combo_box
function settings_controls.add_choice(page, label, choices, selected, on_change)
    page:AddText(label)
    return page:AddComboBox({
        entries = entries(choices),
        selectedID = index_of(choices, selected),
        maxVisibleEntries = dropdown_entries_shown,
        -- Picking an entry also deselects the old one, which comes as its own
        -- change, so only the selected entry counts.
        onChange = function (_, index, _, event_type)
            local choice = choices[index]
            if choice and event_type == ui.SelectionChangeEvent.SELECTED then
                on_change(choice.id)
            end
        end
    })
end

-- How wide checkboxes with these labels need to be. prettyui makes a group as
-- wide as the page unless given a width, and a checkbox's tooltip shows to the
-- right of its row, so a full-width row puts it outside the window instead of
-- by the label.
---@param items { text: string }[]
---@return integer
function settings_controls.checkbox_width(items)
    return (prettyui.CheckboxButton.getSize(items))
end

-- A single checkbox for an on/off setting.
---@param page table
---@param text string
---@param tooltip string
---@param selected boolean
---@param on_change fun(selected: boolean)
function settings_controls.add_toggle(page, text, tooltip, selected, on_change)
    local items = { { text = text, value = text, selected = selected, tooltip = tooltip } }
    page:AddCheckboxButton(items, {
        width = settings_controls.checkbox_width(items),
        onChange = function (_, _, _, now_selected)
            on_change(now_selected)
        end
    })
end

-- A slider with a label above it showing its value, like "Stays: 3 s".
---@param page table
---@param options { label: fun(value: number): string, min: number, max: number, step: number, value: number, tooltip: string, on_change: fun(value: number) }
function settings_controls.add_slider(page, options)
    local label = page:AddText(options.label(options.value))
    page:AddSlider({
        min = options.min,
        max = options.max,
        step = options.step,
        value = options.value,
        tooltip = options.tooltip,
        onChange = function (_, value)
            label.content = options.label(value)
            options.on_change(value)
        end
    })
end

-- Where a font and font size setting is saved, like the area titles' or
-- YOU DIED's.
---@class FontSetting
---@field get_font fun(): string
---@field set_font fun(font: string)
---@field get_size fun(): string
---@field set_size fun(size: string)

-- The area titles' font and size.
---@type FontSetting
settings_controls.title_font = {
    get_font = db.get_font, set_font = db.set_font,
    get_size = db.get_font_size, set_size = db.set_font_size,
}

-- A font and font size. The size can't be picked for fonts that only come in
-- one size.
---@param page table
---@param setting FontSetting
function settings_controls.add_font_choices(page, setting)
    local size_choice
    settings_controls.add_choice(page, "Font", area_title.fonts, setting.get_font(), function (font)
        setting.set_font(font)
        if size_choice then
            size_choice:SetDisabled(not area_title.font_has_sizes(font))
        end
    end)
    size_choice = settings_controls.add_choice(page, "Font size", area_title.sizes, setting.get_size(),
        setting.set_size)
    if size_choice then
        size_choice:SetDisabled(not area_title.font_has_sizes(setting.get_font()))
    end
end

-- 1.5 -> "1.5 s"
---@param seconds number
---@return string
function settings_controls.seconds_text(seconds)
    return string.format("%.1f s", seconds)
end

-- Where fade times are saved, like the area titles' or YOU DIED's.
---@class FadeSetting
---@field get fun(): number, number, number Fade in, stay and fade out, in seconds
---@field set_fade_in fun(seconds: number)
---@field set_stay fun(seconds: number)
---@field set_fade_out fun(seconds: number)

-- Sliders for how long something fades in, stays and fades out.
---@param page table
---@param what string What fades, for the tooltips, like "the title"
---@param setting FadeSetting
function settings_controls.add_fade_sliders(page, what, setting)
    local fade_in, stay, fade_out = setting.get()
    settings_controls.add_slider(page, {
        label = function (seconds) return "Fade in: " .. settings_controls.seconds_text(seconds) end,
        min = 0,
        max = 3,
        step = 0.5,
        value = fade_in,
        tooltip = "How long " .. what .. " takes to appear",
        on_change = setting.set_fade_in,
    })
    settings_controls.add_slider(page, {
        label = function (seconds) return "Stays: " .. settings_controls.seconds_text(seconds) end,
        min = 0.5,
        max = 10,
        step = 0.5,
        value = stay,
        tooltip = "How long " .. what .. " stays before fading out",
        on_change = setting.set_stay,
    })
    settings_controls.add_slider(page, {
        label = function (seconds) return "Fade out: " .. settings_controls.seconds_text(seconds) end,
        min = 0,
        max = 3,
        step = 0.5,
        value = fade_out,
        tooltip = "How long " .. what .. " takes to disappear",
        on_change = setting.set_fade_out,
    })
end

---@param page table
function settings_controls.add_sound_toggle(page)
    settings_controls.add_toggle(page, "Play a sound",
        "Plays a sound as an area's name appears. Needs the game's sound effects turned on",
        db.get_sound_on(), db.set_sound_on)
end

-- Shows the title for where the player is, or an example when that's nowhere
-- named.
---@param page table
function settings_controls.add_preview_button(page)
    page:AddSimpleButton("Preview", function ()
        local name, subtitle, sprite, sound = world_tracker.current_title()
        if name then
            area_title.show(name, subtitle, sprite, sound)
        else
            area_title.preview()
        end
    end)
end

return settings_controls
