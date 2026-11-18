-- The choices for how a title looks (the fonts, sizes and colours on the settings pages), and
-- fitting a text to a font. Each choice has the id it's saved as, and the label shown on the
-- settings page.
local title_styles = {}

-- What apostrophes in names are shown as, unless the font says otherwise (see
-- title_styles.fonts). Most fonts draw a plain ' low, like a comma, or not at
-- all, and have no curly one, so it's swapped for a grave accent.
local default_apostrophe = "`"

-- Fonts only come in fixed sizes, so each font has one for the title and one
-- for the subtitle at each of the sizes below. A font whose spaces look too
-- narrow in titles at a size can have title_spaces: how many spaces each one
-- becomes at that size. A font that has a curly apostrophe sets apostrophe to
-- it, since a grave accent looks wrong in a plain font. A font with only
-- capital letters sets uppercase, as it leaves lower case ones out.
title_styles.fonts = {
    {
        id = "cinzel", label = "Cinzel",
        title = { small = id.Font.CINZEL_48PT_BOLD, medium = id.Font.CINZEL_72PT_BOLD, large = id.Font.CINZEL_90PT_BOLD },
        subtitle = { small = id.Font.CINZEL_18PT_BOLD, medium = id.Font.CINZEL_25PT_BOLD_MULTILINE, large = id.Font.CINZEL_35PT_BOLD },
        title_spaces = { large = 2 },
    },
    {
        id = "museo", label = "Museo Sans",
        apostrophe = "\u{2019}",
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
        uppercase = true,
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
        apostrophe = "\u{2019}",
        title = { small = id.Font.NOTOSANS_BOLD_36, medium = id.Font.NOTOSANS_BOLD_44, large = id.Font.NOTOSANS_BOLD_50 },
        subtitle = { small = id.Font.NOTOSANS_BOLD_18, medium = id.Font.NOTOSANS_BOLD_21, large = id.Font.NOTOSANS_BOLD_24 },
    },
}

-- How far below the title the subtitle starts, in pixels, grows with the title.
title_styles.sizes = {
    { id = "small", label = "Small", subtitle_gap = 60 },
    { id = "medium", label = "Medium", subtitle_gap = 80 },
    { id = "large", label = "Large", subtitle_gap = 100 },
}

title_styles.colours = {
    { id = "white", label = "White", rgb = 0xFFFFFF },
    { id = "parchment", label = "Parchment", rgb = 0xF0E6C8 },
    { id = "gold", label = "RuneScape gold", rgb = 0xE3BB5B },
    { id = "dark_gold", label = "Dark gold", rgb = 0xB8913E },
    -- The colour picked in the settings window (db.get_custom_colour).
    { id = "custom", label = "Custom" },
}

-- The choice with the given id, or the first one if it's not there (like an
-- id saved by an older version).
---@generic Choice : { id: string }
---@param choices Choice[]
---@param choice_id string
---@return Choice
function title_styles.find(choices, choice_id)
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
function title_styles.font_has_sizes(font_id)
    local font = title_styles.find(title_styles.fonts, font_id)
    return font.title.small ~= font.title.large
end

-- The font with this id in title_styles.fonts, or the first one if it isn't there.
---@param font_id string
function title_styles.find_font(font_id)
    return title_styles.find(title_styles.fonts, font_id)
end

-- The size with this id in title_styles.sizes, or the first one if it isn't there.
---@param size_id string
function title_styles.find_size(size_id)
    return title_styles.find(title_styles.sizes, size_id)
end

-- The text with its apostrophes swapped for the ones this font draws well,
-- and in capitals if it only has those.
---@param text string
---@param font table An entry in title_styles.fonts
---@return string
local function fit_to_font(text, font)
    if font.uppercase then
        text = text:upper()
    end
    return (text:gsub("'", font.apostrophe or default_apostrophe))
end

-- A title as it's drawn in this font and size: fitted to the font (see
-- fit_to_font) and spaces widened where the font needs it.
---@param text string
---@param font table An entry in title_styles.fonts
---@param size table An entry in title_styles.sizes
---@return string
function title_styles.title_text(text, font, size)
    local spaces = string.rep(" ", font.title_spaces and font.title_spaces[size.id] or 1)
    return (fit_to_font(text, font):gsub(" ", spaces))
end

-- A subtitle as it's drawn in this font (see fit_to_font).
---@param text string
---@param font table An entry in title_styles.fonts
---@return string
function title_styles.subtitle_text(text, font)
    return fit_to_font(text, font)
end

return title_styles
