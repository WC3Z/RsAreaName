-- The plugin's page: the settings for how the area titles look and sound. Dev
-- builds also have a tab with the mapping tools (src/mapping), which release
-- builds leave out.
local db = require("src/database/db")
local area_title = require("src/ui/area_title")
local world_tracker = require("src/tracker/world_tracker")
-- nil in release builds, which don't have src/mapping.
local has_mapping_tools = pcall(require, "src/mapping/borders_page")
local borders_page = has_mapping_tools and require("src/mapping/borders_page") or nil

local content_view = {}

local subscription_name = "area-names-content"

local view

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
---@param page table The tab page to add it to
---@param label string
---@param choices { id: string, label: string }[]
---@param selected string
---@param on_change fun(choice_id: string)
---@return table combo_box
local function add_choice(page, label, choices, selected, on_change)
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

---@param page table
local function add_settings_page(page)
    -- The size can't be picked for fonts that only come in one size.
    local size_choice
    add_choice(page, "Font", area_title.fonts, db.get_font(), function (font)
        db.set_font(font)
        if size_choice then
            size_choice:SetDisabled(not area_title.font_has_sizes(font))
        end
    end)
    size_choice = add_choice(page, "Font size", area_title.sizes, db.get_font_size(), db.set_font_size)
    if size_choice then
        size_choice:SetDisabled(not area_title.font_has_sizes(db.get_font()))
    end
    add_choice(page, "Colour", area_title.colours, db.get_colour(), db.set_colour)

    page:AddCheckboxButton({
        {
            text = "Show shields",
            value = "showShield",
            selected = db.get_show_shield(),
            tooltip = "Shows an area's lodestone shield above its name, if it has one"
        }
    },
        {
            onChange = function (_, _, _, selected)
                db.set_show_shield(selected)
            end
        })

    page:AddCheckboxButton({
        {
            text = "Play a sound",
            value = "soundOn",
            selected = db.get_sound_on(),
            tooltip = "Plays a sound as an area's name appears. Needs the game's sound effects turned on"
        }
    },
        {
            onChange = function (_, _, _, selected)
                db.set_sound_on(selected)
            end
        })

    add_choice(page, "Sound", area_title.sounds, db.get_sound(), function (sound)
        db.set_sound(sound)
        -- So the sound can be heard while picking one.
        area_title.play_sound()
    end)

    page:AddText("Repeat titles after (minutes)")
    page:AddSlider({
        min = 0,
        max = 5,
        step = 1,
        value = db.get_repeat_minutes(),
        tooltip = "How long before an area's title shows again when you walk back in. 0 shows it every time. Arriving by teleport always shows it",
        onChange = function (_, minutes)
            db.set_repeat_minutes(minutes)
        end
    })

    page:AddSimpleButton("Preview", function ()
        -- Where the player is, or the example when that's nowhere named.
        local name, subtitle, sprite = world_tracker.current_title()
        if name then
            area_title.show(name, subtitle, sprite)
        else
            area_title.preview()
        end
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
    if view then
        view:Destroy()
        view = nil
    end
end

return content_view
