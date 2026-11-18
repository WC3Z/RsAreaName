-- A title's phases over time.
package.path = "./?.lua;" .. package.path
local TitleTiming = require("src/ui/title_timing")

local timing = TitleTiming.new()
assert(timing.phase == "hidden" and timing:advance(1) == nil, "hidden until started")
assert(not timing:begin_fading_away(2), "nothing to fade away while hidden")

-- showing: fades in over 1 second, stays 3, fades out over 2
timing:start(1, 3, 2)
assert(timing.phase == "showing" and timing.alpha == 0, "starts invisible")
assert(not timing:begin_fading_away(2), "nothing visible to fade away yet")
assert(timing:advance(0.5) == "showing" and timing.alpha == 0.5, "fading in")
assert(timing:advance(1) == "showing" and timing.alpha == 1, "staying")
assert(timing:advance(3.5) == "showing" and timing.alpha == 0.5, "fading out")
assert(timing:advance(1) == "finished" and timing.phase == "hidden" and timing.alpha == 0, "finished and hidden")
assert(timing:advance(1) == nil, "and stays hidden")

-- fading away early from fully visible takes the whole fade-out time
timing:start(1, 3, 2)
timing:advance(2)
assert(timing:begin_fading_away(2) and timing.phase == "fading_away", "fades away")
assert(timing:begin_fading_away(5), "asked again while fading: still fading, at the same speed")
assert(timing:advance(1) == "fading_away" and timing.alpha == 0.5, "half way after half the time")
assert(timing:advance(1) == "faded_away" and timing.phase == "hidden", "then it's gone")

-- from half visible it takes half the time
timing:start(1, 3, 2)
timing:advance(0.5)
assert(timing:begin_fading_away(2), "fades away from half visible")
assert(timing:advance(0.5) == "fading_away" and timing.alpha == 0.25, "from where it was")
assert(timing:advance(0.5) == "faded_away", "in half the time")

-- with no fade-out time there's nothing to wait for
timing:start(1, 3, 2)
timing:advance(2)
assert(not timing:begin_fading_away(0) and timing.phase == "showing", "no fade-out time: not fading away")

-- starting again while showing begins from the start
timing:start(1, 3, 2)
timing:advance(2)
timing:start(2, 1, 1)
assert(timing.alpha == 0 and timing:advance(1) == "showing" and timing.alpha == 0.5, "started over with the new times")
timing:hide()
assert(timing.phase == "hidden" and timing:advance(1) == nil, "hidden on demand")
