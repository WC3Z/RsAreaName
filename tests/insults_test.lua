-- Picking an insult for a death.
package.path = "./?.lua;" .. package.path
local insults = require("src/game/insults")

local real_insults = insults.all
insults.all = {
    { text = "always" },
    { text = "also always" },
    { text = "only at a boss", when = function (context) return context.boss == "Boss" end },
}

-- Insults that only fit sometimes are left out when they don't.
for _ = 1, 200 do
    local text = insults.pick({})
    assert(text == "always" or text == "also always", "one that doesn't fit this death isn't picked: " .. tostring(text))
end

-- One that fits this death in particular is picked now and then.
local boss_picks = 0
for _ = 1, 2000 do
    if insults.pick({ boss = "Boss" }) == "only at a boss" then
        boss_picks = boss_picks + 1
    end
end
assert(boss_picks > 0 and boss_picks < 2000, "a fitting one is picked sometimes, not always: " .. boss_picks)

-- The same insult doesn't show twice in a row when there are others.
local last = nil
for _ = 1, 200 do
    local text = insults.pick({})
    assert(text ~= last, "not the same one twice in a row")
    last = text
end

-- With only ones that fit in particular, those are all there is.
insults.all = { { text = "only at a boss", when = function (context) return context.boss == "Boss" end } }
assert(insults.pick({ boss = "Boss" }) == "only at a boss", "the only one that fits")
assert(insults.pick({}) == nil, "none fits: none shown")

insults.all = real_insults
for _, insult in ipairs(insults.all) do
    assert(type(insult.text) == "string" and insult.text ~= "", "every insult has a text")
    assert(insult.when == nil or type(insult.when) == "function", insult.text .. ": when is a function")
end
assert(type(insults.pick({ ping = 10, boss = "Vorago" })) == "string", "the real list always has one that fits")
