-- The area's name across the middle of the screen, with a smaller subtitle
-- under it, fading in, staying a while and fading out again. Its look, timing,
-- height on screen and sound are the player's settings (see db).
local db = require("src/database/db")

local area_title = {}

local subscription_name = "area-names-title"

-- What apostrophes in names are shown as. The fonts draw a plain ' low, like a
-- comma, and have no curly one, so it's swapped for a grave accent.
local apostrophe = "`"

-- The choices for each setting. Each has the id it's saved as, and the label
-- shown on the settings page.

-- Fonts only come in fixed sizes, so each font has one for the title and one
-- for the subtitle at each of the sizes below. A font whose spaces look too
-- narrow in titles at a size can have title_spaces: how many spaces each one
-- becomes at that size.
area_title.fonts = {
    {
        id = "cinzel", label = "Cinzel",
        title = { small = id.Font.CINZEL_48PT_BOLD, medium = id.Font.CINZEL_72PT_BOLD, large = id.Font.CINZEL_90PT_BOLD },
        subtitle = { small = id.Font.CINZEL_18PT_BOLD, medium = id.Font.CINZEL_25PT_BOLD_MULTILINE, large = id.Font.CINZEL_35PT_BOLD },
        title_spaces = { large = 2 },
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
    {
        id = "noto_sans", label = "Noto Sans",
        title = { small = id.Font.NOTOSANS_BOLD_36, medium = id.Font.NOTOSANS_BOLD_44, large = id.Font.NOTOSANS_BOLD_50 },
        subtitle = { small = id.Font.NOTOSANS_BOLD_18, medium = id.Font.NOTOSANS_BOLD_21, large = id.Font.NOTOSANS_BOLD_24 },
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
    -- The colour picked in the settings window (db.get_custom_colour).
    { id = "custom", label = "Custom" },
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
    { id = "amascut_meow", label = "Amascut meow", sound = id.Sound.DQB_AMAS_EMOTE_VO_DAMAGE_03 },
    { id = "amascut_snarl", label = "Amascut snarl", sound = id.Sound.DQB_AMAS_EMOTE_VO_SNARLS_01 },
    -- Fanfares, stings, bells, horns and atmosphere
    { id = "theatre_fanfare", label = "Theatre fanfare", sound = id.Sound.CLAN_THEATRE_MUSIC_FANFARE },
    { id = "crafting_fanfare", label = "Crafting fanfare", sound = id.Sound.SKILLCAPE_EMOTE_CRAFTING_FANFARE },
    { id = "achievement", label = "Achievement", sound = id.Sound.CHEEVO_ACHIEVEMENT_COMPLETE_SOUND_V3 },
    { id = "quest_complete", label = "Quest complete", sound = id.Sound.TUT7_UI_QUESTCOMPLETE },
    { id = "dar_quest_complete", label = "Desert quest done", sound = id.Sound.DAR_MU_HET_QUEST_COMPLETE_01 },
    { id = "clue_found", label = "Clue found", sound = id.Sound.OPN_CLUE_FOUND },
    { id = "level_up_sparkle", label = "Level up sparkle", sound = id.Sound.LEVEL_UP_SPARKLE },
    { id = "discovery", label = "Discovery", sound = id.Sound.INVENT_DISCOVERY_SUCCESS },
    { id = "entrance_sting", label = "Entrance sting", sound = id.Sound.PRE_RELEASE_ENTRACE_STING },
    { id = "memory_sting", label = "Memory sting", sound = id.Sound.DOC_MOIA_MEMORY_STING_JINGLE },
    { id = "um_bridge_sting", label = "Um bridge sting", sound = id.Sound.NECRO_AMB_UM_BRIDGE_WIND_STING_01 },
    { id = "well_of_souls", label = "Well of Souls", sound = id.Sound.NECRO_AMB_WELL_OF_SOULS_STINGS_01 },
    { id = "voices_of_seren", label = "Voices of Seren", sound = id.Sound.TREASURE_HUNTER_VOICES_OF_SEREN_START },
    { id = "prifddinas_chimes", label = "Prifddinas chimes", sound = id.Sound.ELFCITY_ENTRANCE_CHIMES },
    { id = "elf_city_bells", label = "Elf city bells", sound = id.Sound.ELF_CITY_BELLS_1 },
    { id = "single_chime", label = "Single chime", sound = id.Sound.TARDDIAD_SINGLE_CHIME_1 },
    { id = "town_crier_bell", label = "Town crier bell", sound = id.Sound.TOWN_CRIER_BELL_RING_1 },
    { id = "church_bell_2", label = "Church bell 2", sound = id.Sound.CHURCH_BELL },
    { id = "fortress_bells", label = "Fortress bells", sound = id.Sound.NOMEL_FORTRESS_BELLS_1 },
    { id = "arena_horn", label = "Arena horn", sound = id.Sound.DOM_ARENA_BLOW_HORN },
    { id = "hornblower", label = "Hornblower", sound = id.Sound.OMGE_HORNBLOWER },
    { id = "prayer_choir", label = "Prayer choir", sound = id.Sound.SKILLCAPE_EMOTE_PRAYER_CHOIR1 },
    { id = "inspiration_choir", label = "Inspiration choir", sound = id.Sound.INVENT_PLAYER_INSPIRATION_SPOTANIM_CHOIR },
    { id = "ominous_bass", label = "Ominous bass", sound = id.Sound.TARDDIAD_OMINOUS_BASS_1 },
    { id = "ominous_drone", label = "Ominous drone", sound = id.Sound.OMGE_OMINOUS_DRONE_1 },
    { id = "gwd_thunder", label = "God Wars thunder", sound = id.Sound.GW2_THUNDER_1 },
    { id = "wilderness_thunder", label = "Wilderness thunder", sound = id.Sound.WILDERNESS_THUNDER_CLAP_1 },
    { id = "qbd_reveal", label = "Queen Black Dragon reveal", sound = id.Sound.QBD_BELLYOFTHEBEAST_REVEAL },
    { id = "tree_reveal", label = "Tree reveal", sound = id.Sound.EYEGLO_TREE_REVEAL },
    { id = "portal_open", label = "Portal open", sound = id.Sound.WIZARDS_TOWER_RUNECRAFT_PORTAL_OPEN },
    { id = "crystal_whoosh", label = "Crystal whoosh", sound = id.Sound.MTX74_CRYSTAL_WHOOSH },
    { id = "death_jingle", label = "Death jingle", sound = id.Sound.DEATH2_JINGLE },
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
-- The layer the title is drawn on.
---@type ui.Component?
local root
-- Where the title and subtitle were put when they were made: how far down the
-- screen (as a part of its height) and how far below the title the subtitle
-- is. Moving them with SetPos afterwards doesn't show in game, so they're made
-- anew to move them.
---@type number?
local made_at_height
---@type integer?
local made_at_gap
-- How long the title has been showing, in seconds, or nil when it isn't.
---@type number?
local shown_for
-- How long the showing title fades in, stays and fades out, in seconds, read
-- from the settings when it starts.
local fade_in_seconds, stay_seconds, fade_out_seconds = 1.0, 3.0, 1.5
-- How visible the showing title is, from 0 to 1.
local shown_alpha = 0
-- Whether the showing title is fading out early, to make way for another or
-- because the player teleported. It takes switch_seconds in all, from how
-- visible it was then (switch_from_alpha).
local fading_away = false
local switch_seconds, switch_seconds_left, switch_from_alpha = 0, 0, 0
-- A title asked for while another was showing: { name, subtitle, sprite }. It
-- shows once the old one has faded away.
---@type { name: string, subtitle: string?, sprite: string? }?
local next_title

-- A line of text as wide as the screen, with its words in the middle.
---@param parent ui.Component
---@param font integer
---@param y integer
---@param height number How far down the screen, as a part of its height
---@return ui.Text
local function new_text(parent, font, y, height)
    local text = ui.Text.new(parent)
    -- 0 wide plus 100% of the screen, 100 high.
    text:SetSize(0, 100, 1.0)
    -- At the screen's left edge, y below the point `height` down.
    text:SetPos(0, y, 0, height)
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
---@param alpha number From 0 (invisible) to 1
local function set_alpha(alpha)
    shown_alpha = alpha
    title.alpha = alpha
    subtitle.alpha = alpha
    if shield then
        shield.alpha = alpha
    end
end

local start_title

local function on_draw(event)
    count_down_sound(event.timeDeltaSecs)
    if not shown_for or not title or not subtitle then
        return
    end
    if fading_away then
        switch_seconds_left = switch_seconds_left - event.timeDeltaSecs
        if switch_seconds_left > 0 then
            set_alpha(switch_from_alpha * switch_seconds_left / switch_seconds)
            return
        end
        fading_away = false
        local waiting = next_title
        next_title = nil
        if waiting then
            start_title(waiting.name, waiting.subtitle, waiting.sprite)
        else
            area_title.hide()
        end
        return
    end
    shown_for = shown_for + event.timeDeltaSecs
    local alpha = alpha_after(shown_for)
    if not alpha then
        area_title.hide()
        return
    end
    set_alpha(alpha)
end

local function destroy_components()
    if title then
        title:Destroy()
    end
    if subtitle then
        subtitle:Destroy()
    end
    if shield then
        shield:Destroy()
    end
    title, subtitle, shield = nil, nil, nil
end

-- Makes the title, subtitle and shield, hidden.
---@param height number How far down the screen the title's top is, as a part of its height
---@param gap integer How far below the title the subtitle is, in pixels
local function make_components(height, gap)
    title = new_text(root, id.Font.CINZEL_72PT_BOLD, 0, height)
    subtitle = new_text(root, id.Font.CINZEL_25PT_BOLD_MULTILINE, gap, height)
    shield = ui.Sprite.new(root)
    shield:SetSize(shield_size, shield_size)
    -- Centred, with its bottom where the title's top is.
    shield:SetPos(-shield_size // 2, -shield_size, 0.5, height)
    shield.hidden = true
    made_at_height, made_at_gap = height, gap
end

-- The colour's 0xRRGGBB.
---@param colour { rgb?: integer }
---@return integer
local function rgb_of(colour)
    -- The custom colour is saved as 0xRRGGBBAA; the alpha isn't used.
    return colour.rgb or db.get_custom_colour() // 0x100
end

-- Gives the title and subtitle the font, size, colour and place on screen
-- from the settings.
local function apply_settings()
    if not root then
        return
    end
    local font = find(area_title.fonts, db.get_font())
    local size = find(area_title.sizes, db.get_font_size())
    local colour = find(area_title.colours, db.get_colour())
    local height = db.get_title_height() / 100
    if height ~= made_at_height or size.subtitle_gap ~= made_at_gap then
        destroy_components()
        make_components(height, size.subtitle_gap)
    end
    title.font = font.title[size.id]
    subtitle.font = font.subtitle[size.id]
    title.rgb = rgb_of(colour)
    subtitle.rgb = rgb_of(colour)
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
    root = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_BOTTOM)
    apply_settings()
    Event.Draw.Subscribe(subscription_name, on_draw)
end

-- The image to show for the sprite with the given name: the plugin's own copy
-- in resources/shields if it has one (lodestone shields, merged with their
-- alpha masks, see tools/shields), or else the game's sprite. nil if neither
-- exists.
---@param sprite_name string?
---@return integer|PluginResource|nil
local function find_sprite(sprite_name)
    if not sprite_name then
        return nil
    end
    local shields = Plugin.resources and Plugin.resources.shields
    local own = shields and (shields[sprite_name] or shields[sprite_name .. ".png"])
    if own then
        return own
    end
    local found, sprite_id = pcall(function() return id.Sprite[sprite_name] end)
    return found and sprite_id or nil
end

-- Starts showing a name from the beginning, straight away, in place of
-- whatever is showing.
---@param name string
---@param subtitle_text string?
---@param sprite_name string? The area's shield, as its name in id.Sprite
start_title = function (name, subtitle_text, sprite_name)
    -- First, as it can make the title, subtitle and shield anew.
    apply_settings()
    if not title or not subtitle or not shield then
        return
    end
    local image = db.get_show_shield() and find_sprite(sprite_name)
    shield.hidden = not image
    if image then
        -- Takes either a game sprite id or a plugin resource.
        shield.sprite = image
        shield.alpha = 0
    end
    fade_in_seconds, stay_seconds, fade_out_seconds = db.get_title_timing()
    local font = find(area_title.fonts, db.get_font())
    local size = find(area_title.sizes, db.get_font_size())
    local spaces = string.rep(" ", font.title_spaces and font.title_spaces[size.id] or 1)
    title.content = (name:gsub("'", apostrophe):gsub(" ", spaces))
    subtitle.content = ((subtitle_text or ""):gsub("'", apostrophe))
    title.alpha = 0
    subtitle.alpha = 0
    shown_alpha = 0
    title.hidden = false
    subtitle.hidden = false
    shown_for = 0
    if db.get_sound_on() then
        area_title.play_sound()
    end
end

-- Starts fading the showing title out, in the "Fade out" time, or less if it
-- was only partly visible. Returns false when there's nothing to fade.
---@return boolean
local function begin_fading_away()
    if not shown_for or shown_alpha <= 0 then
        return false
    end
    if not fading_away then
        local _, _, fade_out = db.get_title_timing()
        switch_from_alpha = shown_alpha
        switch_seconds = fade_out * shown_alpha
        switch_seconds_left = switch_seconds
        fading_away = switch_seconds > 0
    end
    return fading_away
end

-- Fades the showing title out early, like after a teleport, dropping any
-- title waiting to show. A loading screen covers it anyway; without one, it
-- doesn't just vanish.
function area_title.fade_away()
    next_title = nil
    if not begin_fading_away() then
        area_title.hide()
    end
end

-- Shows a name, starting the effect from the beginning. If another name is
-- still showing, it fades out first, and then this one fades in.
---@param name string
---@param subtitle_text string?
---@param sprite_name string? The area's shield, as its name in id.Sprite
function area_title.show(name, subtitle_text, sprite_name)
    if begin_fading_away() then
        -- Only the latest one asked for shows, if several come while fading.
        next_title = { name = name, subtitle = subtitle_text, sprite = sprite_name }
        return
    end
    start_title(name, subtitle_text, sprite_name)
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
    next_title = nil
    fading_away = false
end

-- Shows an example title with the current settings, for the settings page.
function area_title.preview()
    area_title.show("Varrock", "Capital of Misthalin", "THAS_SHIELD_VARROCK")
end

function area_title.stop()
    Event.Draw.Unsubscribe(subscription_name)
    destroy_components()
    if limited_sound then
        limited_sound:Stop()
        limited_sound = nil
    end
    made_at_height, made_at_gap = nil, nil
    root = nil
    shown_for = nil
end

return area_title
