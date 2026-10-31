-- The player's settings, saved between sessions. Font, size, colour and sound
-- are saved as the ids of the choices in area_title (like "cinzel"). Hidden
-- areas are saved one key each, by name.
local Db = {}

local font_key = "font"
local font_size_key = "font_size"
local colour_key = "colour"
local sound_key = "sound"
local sound_on_key = "sound_on"
local show_shield_key = "show_shield"
local repeat_minutes_key = "repeat_minutes"
local custom_colour_key = "custom_colour"
local fade_in_key = "fade_in_seconds"
local stay_key = "stay_seconds"
local fade_out_key = "fade_out_seconds"
local title_height_key = "title_height_percent"
local teleport_delay_key = "teleport_delay_ticks"
local stop_sound_with_title_key = "stop_sound_with_title"
local death_jingle_on_key = "death_jingle_on"
local hidden_area_key_prefix = "hidden_area."
local hidden_instance_key_prefix = "hidden_instance."

-- The kinds of area whose titles can be turned off as a whole.
---@alias AreaKind "kingdoms" | "places" | "bosses" | "heists"
local area_kind_key_prefix = "show_titles."

-- Whether each area is hidden, by name, and each instance, by id, read from
-- PersistentDB the first time it's needed. The tracker asks every game tick.
---@type table<string, boolean>
local hidden_areas = {}
---@type table<integer, boolean>
local hidden_instances = {}

---@param key string
---@param default boolean
---@return boolean
local function get_bool(key, default)
    local saved = PersistentDB:GetBool(key)
    if saved == nil then
        return default
    end
    return saved
end

---@param key string
---@param default number
---@return number
local function get_float(key, default)
    return PersistentDB:GetFloat(key) or default
end

---@param key string
---@param default string
---@return string
local function get_string(key, default)
    local saved = PersistentDB:GetString(key)
    if saved == nil or saved == "" then
        return default
    end
    return saved
end

---@return string
function Db.get_font()
    return get_string(font_key, "cinzel")
end

---@param font string
function Db.set_font(font)
    PersistentDB:SetString(font_key, font)
end

---@return string
function Db.get_font_size()
    return get_string(font_size_key, "medium")
end

---@param size string
function Db.set_font_size(size)
    PersistentDB:SetString(font_size_key, size)
end

---@return string
function Db.get_colour()
    return get_string(colour_key, "gold")
end

---@param colour string
function Db.set_colour(colour)
    PersistentDB:SetString(colour_key, colour)
end

-- Whether a sound plays when a title appears. On until turned off.
---@return boolean
function Db.get_sound_on()
    return get_bool(sound_on_key, true)
end

---@param on boolean
function Db.set_sound_on(on)
    PersistentDB:SetBool(sound_on_key, on)
end

-- Whether an area's shield shows above its name. On until turned off.
---@return boolean
function Db.get_show_shield()
    return get_bool(show_shield_key, true)
end

---@param show boolean
function Db.set_show_shield(show)
    PersistentDB:SetBool(show_shield_key, show)
end

-- How many minutes before an area's title shows again when walking back in.
-- 0 shows it every time; 1 until changed.
---@return integer
function Db.get_repeat_minutes()
    return PersistentDB:GetInt(repeat_minutes_key) or 1
end

---@param minutes integer
function Db.set_repeat_minutes(minutes)
    PersistentDB:SetInt(repeat_minutes_key, minutes)
end

---@return string
function Db.get_sound()
    return get_string(sound_key, "achievement")
end

---@param sound string
function Db.set_sound(sound)
    PersistentDB:SetString(sound_key, sound)
end

-- The colour picked for the "Custom" colour choice, as 0xRRGGBBAA. White
-- until picked.
---@return integer
function Db.get_custom_colour()
    local saved = PersistentDB:GetInt(custom_colour_key)
    if saved == nil then
        return 0xFFFFFFFF
    end
    -- Saved ints come back as signed 32-bit numbers, so most colours come back
    -- negative; this turns them back into 0xRRGGBBAA.
    return saved % 0x100000000
end

---@param colour integer
function Db.set_custom_colour(colour)
    PersistentDB:SetInt(custom_colour_key, colour)
end

-- How long a title takes to fade in, stays, and takes to fade out, in seconds.
---@return number fade_in
---@return number stay
---@return number fade_out
function Db.get_title_timing()
    return get_float(fade_in_key, 1.0), get_float(stay_key, 3.0), get_float(fade_out_key, 1.5)
end

---@param seconds number
function Db.set_fade_in(seconds)
    PersistentDB:SetFloat(fade_in_key, seconds)
end

---@param seconds number
function Db.set_stay(seconds)
    PersistentDB:SetFloat(stay_key, seconds)
end

---@param seconds number
function Db.set_fade_out(seconds)
    PersistentDB:SetFloat(fade_out_key, seconds)
end

-- How far down the screen the title's top is, in percent of the screen's
-- height.
---@return integer
function Db.get_title_height()
    return PersistentDB:GetInt(title_height_key) or 30
end

---@param percent integer
function Db.set_title_height(percent)
    PersistentDB:SetInt(title_height_key, percent)
end

-- Whether titles show for a kind of area. On until turned off.
---@param kind AreaKind
---@return boolean
function Db.get_show_kind(kind)
    return get_bool(area_kind_key_prefix .. kind, true)
end

---@param kind AreaKind
---@param show boolean
function Db.set_show_kind(kind, show)
    PersistentDB:SetBool(area_kind_key_prefix .. kind, show)
end

-- Whether the player has turned off the titles of the area (a kingdom or a
-- place) with this name.
---@param name string
---@return boolean
function Db.is_area_hidden(name)
    local hidden = hidden_areas[name]
    if hidden == nil then
        hidden = get_bool(hidden_area_key_prefix .. name, false)
        hidden_areas[name] = hidden
    end
    return hidden
end

---@param name string
---@param hidden boolean
function Db.set_area_hidden(name, hidden)
    hidden_areas[name] = hidden
    PersistentDB:SetBool(hidden_area_key_prefix .. name, hidden)
end

-- Whether the player has turned off the title of the instance (a boss fight
-- or a heist) with this id. By id, as two bosses are both called Nex.
---@param instance_id integer
---@return boolean
function Db.is_instance_hidden(instance_id)
    local hidden = hidden_instances[instance_id]
    if hidden == nil then
        hidden = get_bool(hidden_instance_key_prefix .. instance_id, false)
        hidden_instances[instance_id] = hidden
    end
    return hidden
end

---@param instance_id integer
---@param hidden boolean
function Db.set_instance_hidden(instance_id, hidden)
    hidden_instances[instance_id] = hidden
    PersistentDB:SetBool(hidden_instance_key_prefix .. instance_id, hidden)
end

-- How many game ticks (0.6 seconds each) titles wait after a teleport, so
-- they don't play under its loading screen. 4 until changed.
---@return integer
function Db.get_teleport_delay_ticks()
    return PersistentDB:GetInt(teleport_delay_key) or 4
end

---@param ticks integer
function Db.set_teleport_delay_ticks(ticks)
    PersistentDB:SetInt(teleport_delay_key, ticks)
end

-- Whether a title's sound stops when the title is gone, rather than playing
-- to its end. Off until turned on.
---@return boolean
function Db.get_stop_sound_with_title()
    return get_bool(stop_sound_with_title_key, false)
end

---@param stop boolean
function Db.set_stop_sound_with_title(stop)
    PersistentDB:SetBool(stop_sound_with_title_key, stop)
end

-- Whether respawning in Death's Office after dying plays the death jingle.
-- On until turned off.
---@return boolean
function Db.get_death_jingle_on()
    return get_bool(death_jingle_on_key, true)
end

---@param on boolean
function Db.set_death_jingle_on(on)
    PersistentDB:SetBool(death_jingle_on_key, on)
end

return Db
