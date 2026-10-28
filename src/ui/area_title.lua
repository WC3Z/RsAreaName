-- The area's name across the middle of the screen, with a smaller subtitle
-- under it, fading in, staying a while and fading out again. Its font, size,
-- colour and sound are the player's settings (see db).
local db = require("src/database/db")

local area_title = {}

local subscription_name = "area-names-title"

-- How long each part of the effect takes, in seconds.
local fade_in_seconds = 1.0
local stay_seconds = 3.0
local fade_out_seconds = 1.5

-- How far down the screen the title's top is, as a part of the screen's
-- height.
local title_height_on_screen = 0.3

-- What apostrophes in names are shown as. The fonts draw a plain ' low, like a
-- comma, so it's swapped for a curly one (written as Windows-1252).
local apostrophe = "\x92"

-- The choices for each setting. Each has the id it's saved as, and the label
-- shown on the settings page.

-- Fonts only come in fixed sizes, so each font has one for the title and one
-- for the subtitle at each of the sizes below.
area_title.fonts = {
    {
        id = "cinzel", label = "Cinzel",
        title = { small = id.Font.CINZEL_48PT_BOLD, medium = id.Font.CINZEL_72PT_BOLD, large = id.Font.CINZEL_90PT_BOLD },
        subtitle = { small = id.Font.CINZEL_18PT_BOLD, medium = id.Font.CINZEL_25PT_BOLD_MULTILINE, large = id.Font.CINZEL_35PT_BOLD },
    },
    {
        id = "museo", label = "Museo Sans",
        title = { small = id.Font.MUSEO_SANS_21PT_BOLD, medium = id.Font.MUSEO_SANS_24PT_BOLD, large = id.Font.MUSEO_SANS_27PT_BOLD },
        subtitle = { small = id.Font.MUSEO_SANS_13PT_BOLD, medium = id.Font.MUSEO_SANS_15PT_BOLD, large = id.Font.MUSEO_SANS_17PT_BOLD },
    },
    {
        id = "quill", label = "Quill Capitals",
        title = { small = id.Font.QUILL_CAPS_LARGE, medium = id.Font.QUILL_CAPS_LARGE, large = id.Font.QUILL_CAPS_LARGE },
        subtitle = { small = id.Font.QUILL_OBLIQUE_LARGE, medium = id.Font.QUILL_OBLIQUE_LARGE, large = id.Font.QUILL_OBLIQUE_LARGE },
    },
    {
        id = "scratched", label = "Scratched",
        title = { small = id.Font.LUC2_FONT_SCRATCH_LARGE, medium = id.Font.LUC2_FONT_SCRATCH_LARGE, large = id.Font.LUC2_FONT_SCRATCH_LARGE },
        subtitle = { small = id.Font.LUC2_FONT_SCRATCH, medium = id.Font.LUC2_FONT_SCRATCH, large = id.Font.LUC2_FONT_SCRATCH },
    },
    {
        id = "surok", label = "Surok",
        title = { small = id.Font.SUROK_FONT, medium = id.Font.SUROK_FONT, large = id.Font.SUROK_FONT },
        subtitle = { small = id.Font.SUROK_FONT, medium = id.Font.SUROK_FONT, large = id.Font.SUROK_FONT },
    },
}

-- How far below the title the subtitle starts, in pixels, grows with the title.
area_title.sizes = {
    { id = "small", label = "Small", subtitle_gap = 60 },
    { id = "medium", label = "Medium", subtitle_gap = 80 },
    { id = "large", label = "Large", subtitle_gap = 100 },
}

area_title.colours = {
    { id = "white", label = "White", rgb = 0xFFFFFF },
    { id = "parchment", label = "Parchment", rgb = 0xF0E6C8 },
    { id = "gold", label = "RuneScape gold", rgb = 0xE3BB5B },
    { id = "dark_gold", label = "Dark gold", rgb = 0xB8913E },
}

-- Game sounds, from id.Sound. A sound with seconds is stopped after that long,
-- to only play its start.
area_title.sounds = {
    { id = "church_bell", label = "Church bell", sound = id.Sound._200_ATMOSPHERIC_CHURCH_BELL },
    { id = "fanfare", label = "Fanfare", sound = id.Sound.CHAMPIONS_SCROLL_FANFARE },
    { id = "gong", label = "God Wars gong", sound = id.Sound.GODWARS_GONG },
    { id = "battle_horn", label = "Battle horn", sound = id.Sound.OMGE_DISTANT_BATTLEHORN_1 },
    { id = "teleport_boom", label = "Teleport boom", sound = id.Sound.HOME_TELEPORT_2012_PART_7_BOOM },
    { id = "howling_drone", label = "Howling drone", sound = id.Sound._200_ATMOSPHERIC_HOWLING_DRONE_1 },
    -- Leagues
    { id = "league_master_task", label = "League master", sound = id.Sound.LEAGUE2_MASTER_TASK_COMPLETE },
    { id = "league_elite_task", label = "League elite", sound = id.Sound.LEAGUE2_ELITE_TASK_COMPLETE },
    { id = "league_relic", label = "Relic unlock", sound = id.Sound.LEAGUES_25_RELIC_UNLOCK_EXPLOSION },
    { id = "league_relic_portal", label = "Relic portal", sound = id.Sound.LEAGUES_25_RELIC_UNLOCK_PORTAL },
    { id = "league_tier", label = "Tier select", sound = id.Sound.LEAGUES_25_UI_TIER_SEL_01 },
    { id = "league_teleport", label = "League tele", sound = id.Sound.LEAGUE2_TELE_APPEAR_01 },
    -- Others
    { id = "task_complete", label = "Task complete", sound = id.Sound.TASK_COMPLETE_01 },
    { id = "elder_choir", label = "Elder choir", sound = id.Sound.QUEST_ENDGAME_ELDER_CHOIR_REPLY },
    { id = "elder_ritual", label = "Elder ritual", sound = id.Sound.SUM2_ELDER_RITUAL },
    { id = "boss_drum", label = "Boss drum", sound = id.Sound.FT3_BOSS_DRUM_1 },
    { id = "thunder", label = "Thunder", sound = id.Sound.LOY_THUNDER },
    { id = "ancient_teleport", label = "Ancient tele", sound = id.Sound.WILDERNESS_PORTAL_ANCIENT_MAGE_TELEPORT },
    { id = "ge_trade_ok", label = "GE offer done", sound = id.Sound.GE_TRADE_OK },
    { id = "ge_collect_coins", label = "GE coins", sound = id.Sound.GE_COLLECT_COINS },
    { id = "ge_collect_items", label = "GE items", sound = id.Sound.GE_COLLECT_ITEMS },
    { id = "ge_trade_error", label = "GE trade error", sound = id.Sound.GE_TRADE_ERROR },
    { id = "research_finished", label = "Research done", sound = id.Sound.ARCH_RESEARCH_FINISHED },
    -- Amascut
    { id = "amascut_meow", label = "Amascut meow", sound = id.Sound.DQB_AMAS_EMOTE_VO_SNARLS_01 },
}

-- Sounds the game doesn't have, like a number past the last snarl, are left
-- out, so every choice plays something.
for index = #area_title.sounds, 1, -1 do
    if area_title.sounds[index].sound == nil then
        table.remove(area_title.sounds, index)
    end
end

-- The choice with the given id, or the first one if it's not there (like an
-- id saved by an older version).
---@generic Choice : { id: string }
---@param choices Choice[]
---@param choice_id string
---@return Choice
local function find(choices, choice_id)
    for _, choice in ipairs(choices) do
        if choice.id == choice_id then
            return choice
        end
    end
    return choices[1]
end

-- Whether the font comes in more than one size, so the size setting changes
-- anything for it.
---@param font_id string
---@return boolean
function area_title.font_has_sizes(font_id)
    local font = find(area_title.fonts, font_id)
    return font.title.small ~= font.title.large
end

---@type ui.Text?
local title
---@type ui.Text?
local subtitle
-- The area's shield above its name, like the lodestones', if it has one.
---@type ui.Sprite?
local shield
-- How big the shield is, in pixels.
local shield_size = 96
-- How long the title has been showing, in seconds, or nil when it isn't.
---@type number?
local shown_for

-- A line of text as wide as the screen, with its words in the middle.
---@param parent ui.Component
---@param font integer
---@param y integer
---@return ui.Text
local function new_text(parent, font, y)
    local text = ui.Text.new(parent)
    -- 0 wide plus 100% of the screen, 100 high.
    text:SetSize(0, 100, 1.0)
    -- At the screen's left edge, y below the point title_height_on_screen down.
    text:SetPos(0, y, 0, title_height_on_screen)
    text.font = font
    text.alignHorizontal = ui.AlignMode.CENTRE
    text.alignVertical = ui.AlignMode.CENTRE
    text.isShadowed = true
    text.hidden = true
    return text
end

-- How see-through the title is after it's been showing this long: from 0
-- (invisible) up to 1 while fading in, 1 while it stays, and back down to 0
-- while fading out. nil once it's done.
---@param seconds number
---@return number?
local function alpha_after(seconds)

    -- Gradually show the text more
    if seconds < fade_in_seconds then
        return seconds / fade_in_seconds
    end
    seconds = seconds - fade_in_seconds
    -- Keep the text visible
    if seconds < stay_seconds then
        return 1
    end
    seconds = seconds - stay_seconds
    -- Gradually fade the text out
    if seconds < fade_out_seconds then
        return 1 - seconds / fade_out_seconds
    end
    return nil
end

-- The sound playing with a time limit (see area_title.sounds), and how many
-- seconds it has left.
---@type audio.SoundInstance?
local limited_sound
---@type number
local sound_seconds_left = 0

-- Counts down a limited sound's time, and stops it once it's up.
---@param seconds_passed number
local function count_down_sound(seconds_passed)
    if not limited_sound then
        return
    end
    sound_seconds_left = sound_seconds_left - seconds_passed
    if sound_seconds_left <= 0 then
        limited_sound:Stop()
        limited_sound = nil
    end
end

-- Runs every frame. Adding up the time between frames keeps the fade the same
-- speed whatever the frame rate.
---@param event DrawEventPayload
local function on_draw(event)
    count_down_sound(event.timeDeltaSecs)
    if not shown_for or not title or not subtitle then
        return
    end
    shown_for = shown_for + event.timeDeltaSecs
    local alpha = alpha_after(shown_for)
    if not alpha then
        area_title.hide()
        return
    end
    title.alpha = alpha
    subtitle.alpha = alpha
    if shield then
        shield.alpha = alpha
    end
end

-- Gives the title and subtitle the font, size and colour from the settings.
---@param title_text ui.Text
---@param subtitle_text ui.Text
local function apply_settings(title_text, subtitle_text)
    local font = find(area_title.fonts, db.get_font())
    local size = find(area_title.sizes, db.get_font_size())
    local colour = find(area_title.colours, db.get_colour())
    title_text.font = font.title[size.id]
    subtitle_text.font = font.subtitle[size.id]
    subtitle_text:SetPos(0, size.subtitle_gap, 0, title_height_on_screen)
    title_text.rgb = colour.rgb
    subtitle_text.rgb = colour.rgb
end

-- Plays the sound from the settings, even with sounds turned off, to hear it
-- on the settings page.
function area_title.play_sound()
    local sound = find(area_title.sounds, db.get_sound())
    if not sound.sound then
        return
    end
    -- A sound still playing from before is cut short for the new one.
    if limited_sound then
        limited_sound:Stop()
        limited_sound = nil
    end
    local playing = audio.Play(sound.sound)
    if playing and sound.seconds then
        limited_sound = playing
        sound_seconds_left = sound.seconds
    end
end

function area_title.start()
    -- The bottom plugin layer is under the game's interfaces, so open
    -- interfaces cover the title, like they cover the game world.
    local root = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_BOTTOM)
    title = new_text(root, id.Font.CINZEL_72PT_BOLD, 0)
    subtitle = new_text(root, id.Font.CINZEL_25PT_BOLD_MULTILINE, 80)
    shield = ui.Sprite.new(root)
    shield:SetSize(shield_size, shield_size)
    -- Centred, with its bottom where the title's top is.
    shield:SetPos(-shield_size // 2, -shield_size, 0.5, title_height_on_screen)
    shield.hidden = true
    Event.Draw.Subscribe(subscription_name, on_draw)
end

-- The sprite with the given name in id.Sprite, or nil if the game doesn't
-- have it.
---@param sprite_name string?
---@return integer?
local function find_sprite(sprite_name)
    if not sprite_name then
        return nil
    end
    local found, sprite_id = pcall(function() return id.Sprite[sprite_name] end)
    return found and sprite_id or nil
end

-- Shows a name, starting the effect from the beginning, also if another name
-- is still showing.
---@param name string
---@param subtitle_text string?
---@param sprite_name string? The area's shield, as its name in id.Sprite
function area_title.show(name, subtitle_text, sprite_name)
    if not title or not subtitle then
        return
    end
    local sprite_id = db.get_show_shield() and find_sprite(sprite_name)
    if shield then
        shield.hidden = not sprite_id
        if sprite_id then
            shield.spriteID = sprite_id
            shield.alpha = 0
        end
    end
    apply_settings(title, subtitle)
    title.content = (name:gsub("'", apostrophe))
    subtitle.content = ((subtitle_text or ""):gsub("'", apostrophe))
    title.alpha = 0
    subtitle.alpha = 0
    title.hidden = false
    subtitle.hidden = false
    shown_for = 0
    if db.get_sound_on() then
        area_title.play_sound()
    end
end

-- Hides the title straight away, if one is showing.
function area_title.hide()
    if title and subtitle then
        title.hidden = true
        subtitle.hidden = true
    end
    if shield then
        shield.hidden = true
    end
    shown_for = nil
end

-- Shows an example title with the current settings, for the settings page.
function area_title.preview()
    area_title.show("Varrock", "Capital of Misthalin", "THAS_SHIELD_VARROCK")
end

function area_title.stop()
    Event.Draw.Unsubscribe(subscription_name)
    if title then
        title:Destroy()
    end
    if subtitle then
        subtitle:Destroy()
    end
    if shield then
        shield:Destroy()
    end
    if limited_sound then
        limited_sound:Stop()
        limited_sound = nil
    end
    title = nil
    subtitle = nil
    shield = nil
    shown_for = nil
end

return area_title
