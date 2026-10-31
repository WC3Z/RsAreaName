-- A heading, "All" and "None" buttons, and a checkbox for each area. The areas
-- are listed alphabetically, ignoring a leading "The", not in world_areas'
-- order, so they're easy to find. Each checkbox is known by the area's `key`,
-- or by its name when it has none.
local area_checkboxes = {}

-- "The Wilderness" goes under W, where you'd look for it.
---@param name string
---@return string
local function sort_key(name)
    return (name:lower():gsub("^the ", ""))
end

---@param page        table           The prettyui page to add them to
---@param heading     string
---@param areas       { name: string, key?: string }[]
---@param is_checked  fun(key: string): boolean
---@param set_checked fun(keys: string[], checked: boolean)
function area_checkboxes.add(page, heading, areas, is_checked, set_checked)
    local sorted = {}
    for _, area in ipairs(areas) do
        table.insert(sorted, area)
    end
    table.sort(sorted, function (a, b) return sort_key(a.name) < sort_key(b.name) end)
    local keys = {}
    local items = {}
    for _, area in ipairs(sorted) do
        local key = area.key or area.name
        table.insert(keys, key)
        table.insert(items, { text = area.name, value = key, selected = is_checked(key) })
    end

    page:AddTitle(heading)
    local checkboxes
    local function set_all(checked)
        set_checked(keys, checked)
        for _, key in ipairs(keys) do
            checkboxes:SetSelected(key, checked, false)
        end
    end
    page:AddSimpleButton("All " .. heading:lower(), function () set_all(true) end)
    page:AddSimpleButton("No " .. heading:lower(), function () set_all(false) end)
    checkboxes = page:AddCheckboxButton(items, {
        onChange = function (_, _, key, checked)
            set_checked({ key }, checked)
        end
    })
end

return area_checkboxes
