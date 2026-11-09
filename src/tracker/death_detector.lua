-- Tells when the player dies, for the death screen. Usually their lifepoints
-- (the LIFEPOINTS var) drop to 0 and stay there. In testing, a death kept them
-- at 0 for 5 ticks, until the player respawned in Death's Office.
--
-- It only counts once they've stayed at 0 for a couple of ticks, because
-- something that saves the player at 0 lifepoints, like a Sign of Life, might
-- briefly send 0 before putting them back up. Whether it does is unverified.
--
-- A heal on the tick the player dies (like from a Necromancy ghost) means 0 is
-- never sent. That death is caught when they respawn instead, later: on that
-- tick their lifepoints are filled up and their gravestone timer
-- (GRAVESTONE_TIMER_SLOTS) goes up. Either alone can happen without dying,
-- like a full heal or a blessed gravestone, but not both on one tick.
local death_detector = {}

local subscription_name = "area-names-death"

local lifepoints_var = "LIFEPOINTS"
local max_lifepoints_var = "MAXLIFEPOINTS"
local gravestone_var = "GRAVESTONE_TIMER_SLOTS"
-- How many ticks lifepoints have to stay at 0 to count as a death. A death
-- was at 0 for 5, so this has to stay below that.
local confirm_ticks = 2
-- A respawn this soon after a death was counted is that same death.
local same_death_ticks = 10

local tick = 0
-- How many ticks lifepoints have been at 0 since they dropped, or nil when
-- they aren't at 0 (or a death was already counted). The tick they dropped on
-- doesn't count, so it starts at -1: the game sends the var before the tick
-- ends.
---@type integer?
local ticks_at_zero
---@type integer?
local lifepoints
---@type integer?
local max_lifepoints
-- What changed this tick, checked once the tick's vars have all come in.
local lifepoints_changed = false
local gravestone_rose = false
-- The tick the last death was counted on.
---@type integer?
local death_tick
---@type fun()?
local on_death

local function count_death()
    death_tick = tick
    ticks_at_zero = nil
    on_death()
end

---@param event VarTransmitEventPayload
local function on_var(event)
    local name = event.var.configName
    if name == lifepoints_var then
        lifepoints = event.newValue
        lifepoints_changed = true
        if event.newValue == 0 and event.oldValue > 0 then
            ticks_at_zero = -1
        elseif event.newValue > 0 then
            ticks_at_zero = nil
        end
    elseif name == max_lifepoints_var then
        max_lifepoints = event.newValue
    elseif name == gravestone_var and event.newValue > event.oldValue then
        gravestone_rose = true
    end
end

---@return boolean
local function respawned_this_tick()
    return gravestone_rose and lifepoints_changed and lifepoints == max_lifepoints
end

local function on_tick()
    tick = tick + 1
    local respawned = respawned_this_tick()
    lifepoints_changed, gravestone_rose = false, false

    if ticks_at_zero then
        ticks_at_zero = ticks_at_zero + 1
        if ticks_at_zero >= confirm_ticks then
            count_death()
            return
        end
    end
    if respawned and not (death_tick and tick - death_tick <= same_death_ticks) then
        count_death()
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
    ticks_at_zero, lifepoints, max_lifepoints, death_tick = nil, nil, nil, nil
    lifepoints_changed, gravestone_rose = false, false
    on_death = nil
end

return death_detector
