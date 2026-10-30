-- The player's settings, saved between sessions. Font, size, colour and sound
-- are saved as the ids of the choices in area_title (like "cinzel").
local Db = {}

local font_key = "font"
local font_size_key = "font_size"
local colour_key = "colour"
local sound_key = "sound"
local sound_on_key = "sound_on"
local show_shield_key = "show_shield"
local repeat_minutes_key = "repeat_minutes"

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
    local saved = PersistentDB:GetBool(sound_on_key)
    if saved == nil then
        return true
    end
    return saved
end

---@param on boolean
function Db.set_sound_on(on)
    PersistentDB:SetBool(sound_on_key, on)
end

-- Whether an area's shield shows above its name. On until turned off.
---@return boolean
function Db.get_show_shield()
    local saved = PersistentDB:GetBool(show_shield_key)
    if saved == nil then
        return true
    end
    return saved
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

return Db
