-- A Dark Souls style "YOU DIED": the screen darkens a little, a band across
-- the middle darkens more, and "YOU DIED" shows in red on the band. It all
-- fades in, stays a while and fades out again.
local fade = require("src/ui/fade")

local death_screen = {}

local subscription_name = "area-names-death-screen"

-- How dark the screen and the band get, from 0 (not at all) to 1 (black).
local screen_darkness = 0.35
local band_darkness = 0.75
-- How tall the band is, as a part of the screen's height. It's in the middle.
local band_height = 0.2
local text_colour = 0xA01414
local text_font = id.Font.CINZEL_90PT_BOLD
local fade_in_seconds, stay_seconds, fade_out_seconds = 1.5, 4.0, 2.0

---@type ui.Rectangle?
local screen_shade
---@type ui.Rectangle?
local band_shade
---@type ui.Text?
local text
-- How long it has been showing, in seconds, or nil when it isn't.
---@type number?
local shown_for

-- A black rectangle, hidden, `height` (a part of the screen's height) tall
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
    shade.hidden = true
    return shade
end

---@param alpha number From 0 (invisible) to 1
local function set_alpha(alpha)
    screen_shade.alpha = screen_darkness * alpha
    band_shade.alpha = band_darkness * alpha
    text.alpha = alpha
end

---@param hidden boolean
local function set_hidden(hidden)
    screen_shade.hidden = hidden
    band_shade.hidden = hidden
    text.hidden = hidden
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

function death_screen.start()
    -- The same layer as the area titles, under the game's interfaces.
    local root = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_BOTTOM)
    screen_shade = new_shade(root, 1.0)
    band_shade = new_shade(root, band_height)
    text = ui.Text.new(root)
    text:SetSize(0, 0, 1.0, band_height)
    text:SetPos(0, 0, 0, (1 - band_height) / 2)
    text.font = text_font
    text.rgb = text_colour
    text.alignHorizontal = ui.AlignMode.CENTRE
    text.alignVertical = ui.AlignMode.CENTRE
    text.content = "YOU DIED"
    text.hidden = true
    Event.Draw.Subscribe(subscription_name, on_draw)
end

-- Shows it from the beginning, also when it's already showing.
function death_screen.show()
    if not text then
        return
    end
    shown_for = 0
    set_alpha(0)
    set_hidden(false)
end

function death_screen.hide()
    shown_for = nil
    if text then
        set_hidden(true)
    end
end

function death_screen.stop()
    Event.Draw.Unsubscribe(subscription_name)
    for _, component in ipairs({ screen_shade, band_shade, text }) do
        component:Destroy()
    end
    screen_shade, band_shade, text = nil, nil, nil
    shown_for = nil
end

return death_screen
