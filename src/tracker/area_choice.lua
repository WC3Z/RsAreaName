-- Which area's title goes with where the player is. Known instances come
-- first, then places, then kingdoms.
local area_choice = {}

-- The areas the player is in. Any of them can be missing.
---@class Whereabouts
---@field instance WorldInstance?
---@field place    WorldPlace?
---@field kingdom  WorldKingdom?

-- The area the player has just come into, whose title should show, and the
-- subtitle to show with it. Nothing when they're where they were, or have
-- only left something: leaving a place on its own shows nothing.
---@param now              Whereabouts
---@param before           Whereabouts Where they were a moment ago
---@param is_kingdom_shown fun(kingdom: WorldKingdom): boolean Whether the player wants titles for a kingdom
---@return (WorldInstance|WorldPlace|WorldKingdom)? area
---@return string? subtitle
function area_choice.newly_entered(now, before, is_kingdom_shown)
    if now.instance then
        if now.instance ~= before.instance then
            return now.instance, now.instance.subtitle
        end
        return nil, nil
    end
    if now.place then
        if now.place ~= before.place then
            -- The place's own subtitle, or the kingdom it's in.
            return now.place, now.place.subtitle or (now.kingdom and now.kingdom.name)
        end
        return nil, nil
    end
    if now.kingdom and now.kingdom ~= before.kingdom and is_kingdom_shown(now.kingdom) then
        return now.kingdom, nil
    end
    return nil, nil
end

-- The title for where the player is, as it shows when walking in: the known
-- instance, or the place (with its own subtitle, or its kingdom), or the
-- kingdom. Nothing outside every area.
---@param where Whereabouts
---@return string? name
---@return string? subtitle
---@return string? sprite
function area_choice.title_of(where)
    if where.instance then
        return where.instance.name, where.instance.subtitle, where.instance.sprite
    end
    if where.place then
        return where.place.name, where.place.subtitle or (where.kingdom and where.kingdom.name), where.place.sprite
    end
    if where.kingdom then
        return where.kingdom.name, nil, where.kingdom.sprite
    end
    return nil, nil, nil
end

return area_choice
