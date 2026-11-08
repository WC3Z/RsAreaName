-- Tells when the player dies, for the death screen: their lifepoints (the
-- LIFEPOINTS var) drop to 0 and stay there. In testing, a death kept them at 0
-- for 5 ticks, until the player respawned in Death's Office with full
-- lifepoints.
--
-- It only counts once they've stayed at 0 for a couple of ticks, because
-- something that saves the player at 0 lifepoints, like a Sign of Life, might
-- briefly send 0 before putting them back up. Whether it does is unverified.
local death_detector = {}

local subscription_name = "area-names-death"

local lifepoints_var = "LIFEPOINTS"
-- How many ticks lifepoints have to stay at 0 to count as a death. A death
-- was at 0 for 5, so this has to stay below that.
local confirm_ticks = 2

-- How many ticks lifepoints have been at 0 since they dropped, or nil when
-- they aren't at 0 (or a death was already counted). The tick they dropped on
-- doesn't count, so it starts at -1: the game sends the var before the tick
-- ends.
---@type integer?
local ticks_at_zero
---@type fun()?
local on_death

---@param event VarTransmitEventPayload
local function on_var(event)
    if event.var.configName ~= lifepoints_var then
        return
    end
    if event.newValue == 0 and event.oldValue > 0 then
        ticks_at_zero = -1
    elseif event.newValue > 0 then
        ticks_at_zero = nil
    end
end

local function on_tick()
    if not ticks_at_zero then
        return
    end
    ticks_at_zero = ticks_at_zero + 1
    if ticks_at_zero >= confirm_ticks then
        ticks_at_zero = nil
        on_death()
    end
end

---@param callback fun() Called once each time the player dies
function death_detector.start(callback)
    on_death = callback
    Event.VarTransmit.Subscribe(subscription_name, on_var)
    Event.ServerLogic.Subscribe(subscription_name, on_tick)
end

function death_detector.stop()
    Event.VarTransmit.Unsubscribe(subscription_name)
    Event.ServerLogic.Unsubscribe(subscription_name)
    ticks_at_zero = nil
    on_death = nil
end

return death_detector
