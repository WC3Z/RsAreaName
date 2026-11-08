-- The insults that can show under YOU DIED. Some only fit sometimes, like
-- blaming lag when the connection is fine, so they have a `when`: they're only
-- picked when it says yes for how the player died.
local insults = {}

-- What's known about a death, for picking an insult.
---@class DeathContext
---@field ping? integer The ping to the world in ms, or nil when unknown
---@field boss? string The boss fight the player was in, by name (see world_areas.instances), or nil

---@class Insult
---@field text string
---@field when? fun(context: DeathContext): boolean

-- A ping this low (in ms) means lag is no excuse.
local low_ping_ms = 30

---@param context DeathContext
---@return boolean
local function low_ping(context)
    return context.ping ~= nil and context.ping < low_ping_ms
end

---@type Insult[]
insults.all = {
    { text = "Skill issue" },
    { text = "Lmao" },
    { text = "That the best you got?" },
    { text = "Go back to killing goblins instead" },
    { text = "Maybe you'd be better off a skiller" },
    { text = "Sit." },
    { text = "Just retire" },
    -- Implying a vote kick
    { text = "1/4" },
    { text = "Nice hp" },
    { text = "Get this guy off my Clawdia team" },
    { text = "'I ate'" },
    { text = "Unlucky" },
    { text = "Even Bandos would feel sorry for you" },
    { text = "I bet you also asphyx the stun pool" },
    { text = "Lost the omni roulette again?" },
    { text = "Really? YOU are the World Guardian? We're doomed." },
    { text = "You have the survival instincts of a stormtrooper." },
    { text = "Server lag again?", when = low_ping },
    -- OSRS meme - "I tick eat th ose" etc
    { text = "You tick eat th ose" },
    { text = "It make you upset?" },
    { text = "Dsafespot there" },
}

-- The insult shown last time, so the next one is a different one when
-- there's another that fits.
---@type string?
local last_text

-- A random insult that fits the death, or nil when none does.
---@param context DeathContext
---@return string?
function insults.pick(context)
    local fitting = {}
    for _, insult in ipairs(insults.all) do
        if not insult.when or insult.when(context) then
            table.insert(fitting, insult.text)
        end
    end
    if #fitting > 1 then
        for index, text in ipairs(fitting) do
            if text == last_text then
                table.remove(fitting, index)
                break
            end
        end
    end
    if #fitting == 0 then
        return nil
    end
    last_text = fitting[math.random(#fitting)]
    return last_text
end

return insults
