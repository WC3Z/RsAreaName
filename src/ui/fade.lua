local fade = {}

-- How visible something that fades in, stays and fades out is after it's been
-- showing this long: from 0 (invisible) up to 1 while fading in, 1 while it
-- stays, and back down to 0 while fading out. nil once it's done.
---@param seconds number
---@param fade_in_seconds number
---@param stay_seconds number
---@param fade_out_seconds number
---@return number?
function fade.alpha_after(seconds, fade_in_seconds, stay_seconds, fade_out_seconds)
    if seconds < fade_in_seconds then
        return seconds / fade_in_seconds
    end
    seconds = seconds - fade_in_seconds
    if seconds < stay_seconds then
        return 1
    end
    seconds = seconds - stay_seconds
    if seconds < fade_out_seconds then
        return 1 - seconds / fade_out_seconds
    end
    return nil
end

return fade
