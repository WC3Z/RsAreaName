-- A Dark Souls style "YOU DIED": the screen darkens a little, a band across
-- the middle darkens more, and "YOU DIED" shows in red on the band, with an
-- insult under it if the player wants one. It all fades in, stays a while and
-- fades out again.
local db = require("src/database/db")
local area_title = require("src/ui/area_title")
local fade = require("src/ui/fade")

local death_screen = {}

local subscription_name = "area-names-death-screen"

-- How dark the screen and the band get, from 0 (not at all) to 1 (black).
local screen_darkness = 0.35
local band_darkness = 0.75
-- How tall the band is, as a part of the screen's height. It's in the middle.
local band_height = 0.2
-- YOU DIED and the insult under it. The font, size and timing are the
-- player's settings (see db), apart from the area titles'.
local text_colour = 0xA01414
-- How far below the middle of the screen the insult is, in pixels, so it's
-- under YOU DIED. Bigger for bigger font sizes.
local insult_gaps = { small = 35, medium = 45, large = 55 }

local insults = {
    "Skill issue",
    "Lmao",
    "That the best you got?",
    "Go back to killing goblins instead",
    "Maybe you'd be better off a skiller",
    "Sit."
}
-- The insult shown last time, so the next one is a different one.
---@type integer?
local last_insult

---@type ui.Rectangle?
local screen_shade
---@type ui.Rectangle?
local band_shade
---@type ui.Text?
local text
---@type ui.Text?
local insult
-- The layer it's drawn on.
---@type ui.Component?
local root
-- How long it has been showing, in seconds, or nil when it isn't.
---@type number?
local shown_for
local fade_in_seconds, stay_seconds, fade_out_seconds = 1.5, 4.0, 2.0

-- A black rectangle, `height` (a part of the screen's height) tall
-- and as wide as the screen, with its middle in the middle of the screen.
---@param parent ui.Component
---@param height number
---@return ui.Rectangle
local function new_shade(parent, height)
    local shade = ui.Rectangle.new(parent)
    shade:SetSize(0, 0, 1.0, height)
    shade:SetPos(0, 0, 0, (1 - height) / 2)
    shade.fill = true
    shade.rgba = 0x000000FF
    shade.alpha = 0
    return shade
end

---@param alpha number From 0 (invisible) to 1
local function set_alpha(alpha)
    screen_shade.alpha = screen_darkness * alpha
    band_shade.alpha = band_darkness * alpha
    text.alpha = alpha
    insult.alpha = alpha
end

-- A random insult, never the same as last time.
---@return string
local function pick_insult()
    local index
    if last_insult then
        -- One of the others: picks from one fewer and skips over the last one.
        index = math.random(#insults - 1)
        if index >= last_insult then
            index = index + 1
        end
    else
        index = math.random(#insults)
    end
    last_insult = index
    return area_title.subtitle_text(insults[index])
end

---@param event DrawEventPayload
local function on_draw(event)
    if not shown_for then
        return
    end
    shown_for = shown_for + event.timeDeltaSecs
    local alpha = fade.alpha_after(shown_for, fade_in_seconds, stay_seconds, fade_out_seconds)
    if not alpha then
        death_screen.hide()
        return
    end
    set_alpha(alpha)
end

-- Red text as wide as the screen, centred in its box. The box is `height`
-- pixels plus `height_part` of the screen's height tall, and its top is `y`
-- pixels below the point `y_part` of the way down the screen.
---@param y integer
---@param y_part number
---@param height integer
---@param height_part number
---@param font integer
---@return ui.Text
local function new_text(y, y_part, height, height_part, font)
    local line = ui.Text.new(root)
    line:SetSize(0, height, 1.0, height_part)
    line:SetPos(0, y, 0, y_part)
    line.font = font
    line.rgb = text_colour
    line.alignHorizontal = ui.AlignMode.CENTRE
    line.alignVertical = ui.AlignMode.CENTRE
    line.alpha = 0
    return line
end

local function destroy_components()
    for _, component in ipairs({ screen_shade, band_shade, text, insult }) do
        component:Destroy()
    end
    screen_shade, band_shade, text, insult = nil, nil, nil, nil
end

-- Makes it anew with the settings, as moving text afterwards doesn't show in
-- game and the insult's place depends on the font size.
---@param insult_text string
local function make_components(insult_text)
    local font = area_title.find_font(db.get_death_font())
    local size = area_title.find_size(db.get_death_font_size())
    screen_shade = new_shade(root, 1.0)
    band_shade = new_shade(root, band_height)
    text = new_text(0, (1 - band_height) / 2, 0, band_height, font.title[size.id])
    text.content = area_title.title_text("YOU DIED", font, size)
    insult = new_text(insult_gaps[size.id], 0.5, 40, 0, font.subtitle[size.id])
    insult.content = insult_text
end

function death_screen.start()
    -- The same layer as the area titles, under the game's interfaces.
    root = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_BOTTOM)
    Event.Draw.Subscribe(subscription_name, on_draw)
end

-- Shows it from the beginning, also when it's already showing.
function death_screen.show()
    if not root then
        return
    end
    death_screen.hide()
    make_components(db.get_death_insults_on() and pick_insult() or "")
    fade_in_seconds, stay_seconds, fade_out_seconds = db.get_death_timing()
    shown_for = 0
    set_alpha(0)
end

---@param show_screen boolean
local function play(show_screen)
    if show_screen then
        death_screen.show()
    end
    if db.get_death_jingle_on() then
        area_title.play_sound("death_jingle")
    end
end

-- What the settings ask for when the player dies: YOU DIED and the death
-- jingle.
function death_screen.on_death()
    play(db.get_death_screen_on())
end

-- For the settings page: YOU DIED even when it's turned off, and the death
-- jingle if it's on.
function death_screen.preview()
    play(true)
end

function death_screen.hide()
    shown_for = nil
    if text then
        destroy_components()
    end
end

function death_screen.stop()
    Event.Draw.Unsubscribe(subscription_name)
    death_screen.hide()
    root = nil
end

return death_screen
