-- The area's name across the middle of the screen, with a smaller subtitle
-- under it, fading in, staying a while and fading out again. Its look, timing,
-- place on screen and sound are the player's settings (see db). The choices
-- for its look are in title_styles, its sounds in title_sounds, and how its
-- visibility goes over time in title_timing.
local db = require("src/database/db")
local title_styles = require("src/ui/title_styles")
local title_sounds = require("src/ui/title_sounds")
local TitleTiming = require("src/ui/title_timing")

local area_title = {}

local subscription_name = "area-names-title"

-- How big the shield is, in pixels.
local shield_size = 96

-- The layer the title is drawn on, while the plugin runs.
---@type ui.Component?
local root
---@type ui.Text?
local title
---@type ui.Text?
local subtitle
-- The area's shield above its name, like the lodestones', if it has one.
---@type ui.Sprite?
local shield
-- Where the title and subtitle were put when they were made: how far down the
-- screen (as a part of its height) and how far below the title the subtitle
-- is. Moving them with SetPos afterwards doesn't show in game, so they're made
-- anew to move them.
---@type number?
local made_at_y_fraction
---@type integer?
local made_at_gap

-- Which phase the showing title is in, and how visible it is.
local timing = TitleTiming.new()
-- A title asked for while another was showing. It shows once the old one has
-- faded away.
---@type { name: string, subtitle: string?, sprite: string? }?
local next_title
-- The sound the showing title started, to stop it with the title if the
-- player wants (db.get_stop_sound_with_title).
---@type audio.SoundInstance?
local title_sound

-- A line of text as wide as the screen, with its words in the middle.
---@param parent ui.Component
---@param font integer
---@param y integer
---@param y_fraction number How far down the screen, as a part of its height
---@return ui.Text
local function new_text(parent, font, y, y_fraction)
    local text = ui.Text.new(parent)
    -- 0 wide plus 100% of the screen, 100 high.
    text:SetSize(0, 100, 1.0)
    -- At the screen's left edge, y below the point `y_fraction` down.
    text:SetPos(0, y, 0, y_fraction)
    text.font = font
    text.alignHorizontal = ui.AlignMode.CENTRE
    text.alignVertical = ui.AlignMode.CENTRE
    text.isShadowed = true
    text.hidden = true
    return text
end

-- Stops the title's sound, if the player wants it to end with the title.
local function stop_title_sound()
    if title_sound and db.get_stop_sound_with_title() then
        title_sounds.stop(title_sound)
    end
    title_sound = nil
end

---@param alpha number From 0 (invisible) to 1
local function set_alpha(alpha)
    title.alpha = alpha
    subtitle.alpha = alpha
    if shield then
        shield.alpha = alpha
    end
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
---@param y_fraction number How far down the screen the title's top is, as a part of its height
---@param gap integer How far below the title the subtitle is, in pixels
---@param title_font integer
---@param subtitle_font integer
local function make_components(y_fraction, gap, title_font, subtitle_font)
    title = new_text(root, title_font, 0, y_fraction)
    subtitle = new_text(root, subtitle_font, gap, y_fraction)
    shield = ui.Sprite.new(root)
    shield:SetSize(shield_size, shield_size)
    -- Centred, with its bottom where the title's top is.
    shield:SetPos(-shield_size // 2, -shield_size, 0.5, y_fraction)
    shield.hidden = true
    made_at_y_fraction, made_at_gap = y_fraction, gap
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
    local font = title_styles.find_font(db.get_font())
    local size = title_styles.find_size(db.get_font_size())
    local colour = title_styles.find(title_styles.colours, db.get_colour())
    local y_fraction = db.get_title_height() / 100
    if y_fraction ~= made_at_y_fraction or size.subtitle_gap ~= made_at_gap then
        destroy_components()
        make_components(y_fraction, size.subtitle_gap, font.title[size.id], font.subtitle[size.id])
    end
    title.font = font.title[size.id]
    subtitle.font = font.subtitle[size.id]
    title.rgb = rgb_of(colour)
    subtitle.rgb = rgb_of(colour)
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
local function start_title(name, subtitle_text, sprite_name)
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
    end
    local font = title_styles.find_font(db.get_font())
    local size = title_styles.find_size(db.get_font_size())
    title.content = title_styles.title_text(name, font, size)
    subtitle.content = title_styles.subtitle_text(subtitle_text or "", font)
    timing:start(db.get_title_timing())
    set_alpha(0)
    title.hidden = false
    subtitle.hidden = false
    stop_title_sound()
    if db.get_sound_on() then
        title_sound = title_sounds.play()
    end
end

-- Runs every frame.
---@param event DrawEventPayload
local function on_draw(event)
    if not title or not subtitle then
        return
    end
    local doing = timing:advance(event.timeDeltaSecs)
    if doing == "showing" or doing == "fading_away" then
        set_alpha(timing.alpha)
    elseif doing == "finished" then
        area_title.hide()
    elseif doing == "faded_away" then
        local waiting = next_title
        next_title = nil
        if waiting then
            start_title(waiting.name, waiting.subtitle, waiting.sprite)
        else
            area_title.hide()
        end
    end
end

-- Starts fading the showing title out, in the "Fade out" time, or less if it
-- was only partly visible. Returns false when there's nothing to fade.
---@return boolean
local function begin_fading_away()
    local _, _, fade_out_seconds = db.get_title_timing()
    return timing:begin_fading_away(fade_out_seconds)
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
    timing:hide()
    next_title = nil
    stop_title_sound()
end

-- Shows an example title with the current settings, for the settings page.
function area_title.preview()
    area_title.show("Varrock", "Capital of Misthalin", "THAS_SHIELD_VARROCK")
end

function area_title.start()
    -- The bottom plugin layer is under the game's interfaces, so open
    -- interfaces cover the title, like they cover the game world.
    root = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_BOTTOM)
    apply_settings()
    Event.Draw.Subscribe(subscription_name, on_draw)
end

function area_title.stop()
    Event.Draw.Unsubscribe(subscription_name)
    area_title.hide()
    destroy_components()
    made_at_y_fraction, made_at_gap = nil, nil
    root = nil
end

return area_title
