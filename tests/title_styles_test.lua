-- Fitting a title's text to a font, and finding the saved choices.
package.path = "./?.lua;" .. package.path
-- Font ids only need to be there, and different from each other.
id = { Font = setmetatable({}, { __index = function (_, name) return name end }) }
local title_styles = require("src/ui/title_styles")

local cinzel = title_styles.find_font("cinzel")
assert(cinzel.id == "cinzel", "a font by its id")
assert(title_styles.find_font("a font that's gone").id == title_styles.fonts[1].id, "an unknown id gives the first font")
assert(title_styles.find_size("large").id == "large" and title_styles.find_size("?").id == title_styles.sizes[1].id, "sizes the same way")
assert(title_styles.find(title_styles.colours, "gold").rgb == 0xE3BB5B, "and colours")

local small, large = title_styles.find_size("small"), title_styles.find_size("large")
assert(title_styles.title_text("Death's Office", cinzel, small) == "Death`s Office", "apostrophes become ones the font draws well")
assert(title_styles.title_text("War's Retreat", cinzel, large) == "War`s  Retreat", "spaces are widened where the font needs it")
assert(title_styles.subtitle_text("Capital of Misthalin", cinzel) == "Capital of Misthalin", "a subtitle's spaces are left alone")

for _, font in ipairs(title_styles.fonts) do
    for _, size in ipairs(title_styles.sizes) do
        assert(font.title[size.id] and font.subtitle[size.id], font.id .. " has a title and a subtitle font at size " .. size.id)
    end
    if font.uppercase then
        assert(title_styles.title_text("Varrock", font, small) == "VARROCK", font.id .. " only has capitals")
    end
    if font.apostrophe then
        assert(title_styles.subtitle_text("War's", font) == "War" .. font.apostrophe .. "s", font.id .. " has its own apostrophe")
    end
end
local has_sizes, has_one_size = false, false
for _, font in ipairs(title_styles.fonts) do
    if title_styles.font_has_sizes(font.id) then has_sizes = true else has_one_size = true end
end
assert(has_sizes, "some fonts come in several sizes")
