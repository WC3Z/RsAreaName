-- How a title's visibility goes over time. It's in one of three phases:
--
--   hidden        nothing shows
--   showing       it fades in, stays and fades out (see fade), then it's hidden
--   fading_away   it fades out early, from however visible it was, to make way for another title
--                 or because the player teleported; then it's hidden
local fade = require("src/ui/fade")

---@class TitleTiming
---@field phase "hidden"|"showing"|"fading_away"
---@field alpha number How visible the title is, from 0 to 1.
---@field shown_for number How long it's been showing, in seconds.
---@field fade_in_seconds number
---@field stay_seconds number
---@field fade_out_seconds number
---@field fade_away_seconds number How long the fading away takes in all.
---@field fade_away_seconds_left number
---@field fade_away_from_alpha number How visible it was when it began fading away.
local TitleTiming = {}
TitleTiming.__index = TitleTiming

---@return TitleTiming
function TitleTiming.new()
    local self = setmetatable({}, TitleTiming)
    self:hide()
    return self
end

function TitleTiming:hide()
    self.phase = "hidden"
    self.alpha = 0
    self.shown_for = 0
end

-- Starts showing from the beginning.
---@param fade_in_seconds number
---@param stay_seconds number
---@param fade_out_seconds number
function TitleTiming:start(fade_in_seconds, stay_seconds, fade_out_seconds)
    self.phase = "showing"
    self.alpha = 0
    self.shown_for = 0
    self.fade_in_seconds, self.stay_seconds, self.fade_out_seconds = fade_in_seconds, stay_seconds, fade_out_seconds
end

-- Starts fading out early: in the given time if the title is fully visible, less if it's only
-- partly so.
---@param fade_out_seconds number
---@return boolean # Whether it's fading away now. False when there's nothing visible to fade.
function TitleTiming:begin_fading_away(fade_out_seconds)
    if self.phase == "hidden" or self.alpha <= 0 then
        return false
    end
    if self.phase == "fading_away" then
        return true
    end
    local seconds = fade_out_seconds * self.alpha
    if seconds <= 0 then
        return false
    end
    self.phase = "fading_away"
    self.fade_away_from_alpha = self.alpha
    self.fade_away_seconds = seconds
    self.fade_away_seconds_left = seconds
    return true
end

-- Moves time on. Adding up the time between frames keeps the fade the same speed whatever the
-- frame rate.
---@param seconds number Since the last time.
---@return "showing"|"fading_away"|"finished"|"faded_away"|nil # What it's doing now: still showing or fading away (see alpha), or it just finished on its own, or just faded away. Nil while hidden.
function TitleTiming:advance(seconds)
    if self.phase == "hidden" then
        return nil
    end
    if self.phase == "fading_away" then
        self.fade_away_seconds_left = self.fade_away_seconds_left - seconds
        if self.fade_away_seconds_left > 0 then
            self.alpha = self.fade_away_from_alpha * self.fade_away_seconds_left / self.fade_away_seconds
            return "fading_away"
        end
        self:hide()
        return "faded_away"
    end
    self.shown_for = self.shown_for + seconds
    local alpha = fade.alpha_after(self.shown_for, self.fade_in_seconds, self.stay_seconds, self.fade_out_seconds)
    if alpha == nil then
        self:hide()
        return "finished"
    end
    self.alpha = alpha
    return "showing"
end

return TitleTiming
