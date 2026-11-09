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

-- How often an insult that fits this death in particular (one with a
-- `when`, like a boss's) is picked over the ones that always fit, when there
-- is one. Otherwise they'd hardly ever show among the many that always fit.
local situational_chance = 1.0

---@param context DeathContext
---@return boolean
local function low_ping(context)
	return context.ping ~= nil and context.ping < low_ping_ms
end

-- A `when` for dying in any of these boss fights, named as in
-- world_areas.instances, like boss("Vorago", "Telos").
---@param ... string
---@return fun(context: DeathContext): boolean
local function boss(...)
	local names = {}
	for _, name in ipairs({ ... }) do
		names[name] = true
	end
	return function (context)
		return context.boss ~= nil and names[context.boss] == true
	end
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
	{ text = "Nice hp" },
	{ text = "Get this guy off my Clawdia team" },
	{ text = "'I ate'" },
	{ text = "Unlucky" },
	{ text = "Even Bandos would feel sorry for you" },
	{ text = "I bet you also asphyx the stun pool" },
	{ text = "Really? YOU are the World Guardian? We're doomed." },
	{ text = "You have the survival instincts of a stormtrooper." },
	{ text = "What happened?" },
	{ text = "You must be Deaths favourite client" },
	{ text = "Server lag again?", when = low_ping },

	-- Bosses
	{ text = "Died to the Giant Mole. Let that sink in.", when = boss("Giant Mole") },
	{ text = "Forgot your anti-dragon shield?", when = boss("King Black Dragon") },
	{ text = "Forgot your antifire?", when = boss("Queen Black Dragon") },
	{ text = "QBD isn't the only thing that's rotten", when = boss("Queen Black Dragon") },
	{ text = "It took your weapon and your dignity", when = boss("Chaos Elemental") },
	{ text = "Wrong path?", when = boss("Araxxi") },
	{ text = "Rocks fall, you die", when = boss("Vorago") },
	{ text = "Lost the omni roulette again?", when = boss("Vorago") },
	{ text = "Three kings, zero chance", when = boss("Dagannoth Kings") },
	{ text = "Long live the King", when = boss("Kalphite King") },
	{ text = "Chaos wins again", when = boss("Zamorak") },
	{ text = "Cat got your tongue?", when = boss("Amascut") },
	-- Implying a vote kick
	{ text = "1/4", when = boss("Nex: Angel of Death") },
	{ text = "Boss got nerfed and you're still dying.", when = boss("Raksha") },
	{ text = "Even the Corporeal Beast couldn't stomach your presence", when = boss("Corporeal Beast") },
	{ text = "Dug your own grave", when = boss("The Barrows Brothers") },
	{ text = "Grounded.", when = boss("Kree'arra") },
	{ text = "Enrage too high or skill too low?", when = boss("Telos") },
	{ text = "Time's up", when = boss("Kerapac") },
	{ text = "Devourer Eternal. You, not so much.", when = boss("Nakatra") },
	{ text = "Now you're just bones too", when = boss("Ivar") },
	{ text = "Mauled by a tree hugger", when = boss("Helwyr") },
	{ text = "Extinct, just like your skill", when = boss("Rex Matriarchs") },
	{ text = "Two of them, none of you", when = boss("Zemouregal & Vorkath") },
	{ text = "Mother knows best", when = boss("Vermyx") },
	{ text = "Wandered too far", when = boss("Kezalam") },
	{ text = "Dreadhog? More like dead hog. Oh wait, that's you.", when = boss("Silverquill") },
}

-- The insult shown last time, so the next one is a different one when
-- there's another that fits.
---@type string?
local last_text

-- The texts of the insults that fit, leaving out the one shown last time if
-- there are others.
---@param context DeathContext
---@param situational boolean Only the ones with a `when`, or only the ones without
---@return string[]
local function fitting(context, situational)
	local texts = {}
	for _, insult in ipairs(insults.all) do
		if (insult.when ~= nil) == situational and (not insult.when or insult.when(context)) then
			table.insert(texts, insult.text)
		end
	end
	if #texts > 1 then
		for index, text in ipairs(texts) do
		    -- Remove the last shown text to prevent a duplicate entry
			if text == last_text then
				table.remove(texts, index)
				break
			end
		end
	end
	return texts
end

-- A random insult that fits the death, or nil when none does. One that fits
-- this death in particular is picked `situational_chance` of the time.
---@param context DeathContext
---@return string?
function insults.pick(context)
	local situational = fitting(context, true)
	local always = fitting(context, false)
	local texts = always
	if #situational > 0 and (#always == 0 or math.random() < situational_chance) then
		texts = situational
	end
	if #texts == 0 then
		return nil
	end
	last_text = texts[math.random(#texts)]
	return last_text
end

return insults
