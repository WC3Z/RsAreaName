-- A list of areas that can be opened and closed: a heading, an "All ..."
-- checkbox that ticks or unticks every area, and a checkbox for each area.
-- The areas are listed alphabetically, ignoring a leading "The", not in
-- world_areas' order, so they're easy to find. Each checkbox is known by the
-- area's `key`, or by its name when it has none.
--
-- prettyui's collapse sections have no AddCheckboxButton, so the checkboxes
-- are made with prettyui.CheckboxButton.new in the section's content, on top
-- of an empty text that keeps room for them. They're only made the first time
-- the list is opened, as a long list takes a moment to build.
local area_checkboxes = {}

-- The value of the "All ..." checkbox, which no area's key or name can be.
local all_value = "*all*"

-- "The Wilderness" goes under W, where you'd look for it.
---@param name string
---@return string
local function sort_key(name)
    return (name:lower():gsub("^the ", ""))
end

---@class AreaListOptions
---@field expanded boolean Whether the list is open
---@field on_toggle fun(expanded: boolean) Called when the player opens or closes it

---@param page        table           The prettyui page to add them to
---@param heading     string
---@param areas       { name: string, key?: string }[]
---@param is_checked  fun(key: string): boolean
---@param set_checked fun(keys: string[], checked: boolean)
---@param options     AreaListOptions
---@return table section The prettyui collapse section heading the list
function area_checkboxes.add(page, heading, areas, is_checked, set_checked, options)
    local sorted = {}
    for _, area in ipairs(areas) do
        table.insert(sorted, area)
    end
    table.sort(sorted, function (a, b) return sort_key(a.name) < sort_key(b.name) end)
    local keys = {}
    for _, area in ipairs(sorted) do
        table.insert(keys, area.key or area.name)
    end

    local checkboxes

    local function all_checked()
        for _, key in ipairs(keys) do
            if not is_checked(key) then
                return false
            end
        end
        return true
    end

    local function on_change(_, _, key, checked)
        if key == all_value then
            set_checked(keys, checked)
            for _, area_key in ipairs(keys) do
                checkboxes:SetSelected(area_key, checked, false)
            end
        else
            set_checked({ key }, checked)
            checkboxes:SetSelected(all_value, all_checked(), false)
        end
    end

    ---@param section table
    local function add_checkboxes(section)
        -- The first row is "All places" and so on, ticked while every area is.
        local items = { { text = "All " .. heading:lower(), value = all_value, selected = all_checked() } }
        for i, area in ipairs(sorted) do
            table.insert(items, { text = area.name, value = keys[i], selected = is_checked(keys[i]) })
        end
        local _, height = prettyui.CheckboxButton.getSize(items)
        local room = section:AddText({ text = "", height = height })
        checkboxes = prettyui.CheckboxButton.new(section.content, items, {
            y = room.y,
            width = 0,
            widthAnchor = 1.0,
            -- So the mouse wheel still scrolls the tab over the checkboxes, like
            -- it does over what prettyui adds to the section itself. This is
            -- prettyui's own internal field, not part of its documented API.
            _onScrollWheel = section._onScrollWheel,
            onChange = on_change,
        })
    end

    local section
    section = page:AddCollapseButton(heading .. " (" .. #sorted .. ")", {
        expanded = options.expanded,
        onToggle = function (_, expanded)
            if expanded and not checkboxes then
                add_checkboxes(section)
            end
            options.on_toggle(expanded)
        end
    })
    if options.expanded then
        add_checkboxes(section)
    end
    return section
end

return area_checkboxes
