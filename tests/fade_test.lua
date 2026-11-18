-- How visible something that fades in, stays and fades out is over time.
package.path = "./?.lua;" .. package.path
local fade = require("src/ui/fade")

assert(fade.alpha_after(0, 1, 3, 2) == 0, "invisible at the start")
assert(fade.alpha_after(0.5, 1, 3, 2) == 0.5, "half way in, half visible")
assert(fade.alpha_after(1, 1, 3, 2) == 1, "fully visible once faded in")
assert(fade.alpha_after(3.9, 1, 3, 2) == 1, "and while it stays")
assert(fade.alpha_after(5, 1, 3, 2) == 0.5, "half way out, half visible")
assert(fade.alpha_after(6, 1, 3, 2) == nil, "done after fading out")
assert(fade.alpha_after(0, 0, 3, 2) == 1, "no fade in: visible right away")
assert(fade.alpha_after(3, 0, 3, 0) == nil, "no fade out: done when the stay is over")
