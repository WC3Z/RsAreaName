-- The named places in the game world: places outside the towns and kingdoms
-- (like War's Retreat, or where an instance is copied from), towns, each a
-- circle around its middle, and kingdoms. Places and kingdoms are made of one
-- or more rectangles. All positions are world tiles (CoordGrid.x and
-- CoordGrid.z); a map square is 64 of them.
local world_areas = {}

---@class WorldTown
---@field name string
---@field subtitle? string
---@field sprite? string A sprite shown above the name, as its name in id.Sprite
---@field at integer[] { world tile x, world tile z } of its middle
---@field radius integer In tiles

---@class WorldKingdom
---@field name string
---@field sprite? string A sprite shown above the name, as its name in id.Sprite
---@field bounds integer[][] Rectangles, each { min x, min z, max x, max z } in world tiles (both ends included)

---@class WorldPlace
---@field name string
---@field subtitle? string
---@field sprite? string A sprite shown above the name, as its name in id.Sprite
---@field bounds integer[][] Rectangles, like a kingdom's

-- Places away from the main world: worlds of their own, and the places
-- instances are copied from (see World.GetRegionSourceForCoordGrid).
---@type WorldPlace[]
world_areas.places = {
    -- Map square 6, 10
    { name = "Death's Office", bounds = { { 384, 640, 447, 703 } } },
    -- Map squares 50, 158 to 51, 158
    { name = "War's Retreat", bounds = { { 3200, 10112, 3327, 10175 } } },
    -- Map square 59, 110
    { name = "Telos", subtitle = "The Warden", bounds = { { 3776, 7040, 3839, 7103 } } },
}

---@type WorldTown[]
world_areas.towns = {
    -- Misthalin
    { name = "Lumbridge", sprite = "THAS_SHIELD_LUMBRIDGE", at = { 3222, 3218 }, radius = 30 },
    { name = "Draynor Village", sprite = "THAS_SHIELD_DRAYNOR", at = { 3093, 3244 }, radius = 30 },
    { name = "Varrock", sprite = "THAS_SHIELD_VARROCK", subtitle = "Capital of Misthalin", at = { 3213, 3428 }, radius = 55 },
    { name = "Grand Exchange", at = { 3165, 3487 }, radius = 20 },
    { name = "Edgeville", sprite = "THAS_SHIELD_EDGEVILLE", at = { 3093, 3493 }, radius = 25 },
    { name = "Barbarian Village", at = { 3082, 3420 }, radius = 20 },
    -- Asgarnia
    { name = "Falador", sprite = "THAS_SHIELD_FALADOR", subtitle = "Capital of Asgarnia", at = { 2965, 3380 }, radius = 45 },
    { name = "Port Sarim", sprite = "THAS_SHIELD_PORTSARIM", at = { 3023, 3208 }, radius = 30 },
    { name = "Rimmington", at = { 2957, 3214 }, radius = 25 },
    { name = "Taverley", sprite = "THAS_SHIELD_TAVERLY", at = { 2894, 3456 }, radius = 30 },
    { name = "Burthorpe", sprite = "THAS_SHIELD_BURTHORPE", at = { 2899, 3544 }, radius = 30 },
    -- Kandarin
    { name = "Catherby", sprite = "THAS_SHIELD_CATHERBY", at = { 2813, 3447 }, radius = 30 },
    { name = "Seers' Village", sprite = "THAS_SHIELD_SEERS", at = { 2726, 3485 }, radius = 30 },
    { name = "East Ardougne", sprite = "THAS_SHIELD_ARDOUNGE", subtitle = "Capital of Kandarin", at = { 2662, 3305 }, radius = 45 },
    { name = "Yanille", sprite = "THAS_SHIELD_YANILLE", at = { 2606, 3093 }, radius = 30 },
    { name = "West Ardougne", subtitle = "Capital of West Kandarin", at = { 2535, 3305 }, radius = 40 },
    { name = "Gnome Stronghold", subtitle = "Gnomish Kingdom", at = { 2460, 3440 }, radius = 45 },
    { name = "Tree Gnome Village", subtitle = "Gnomish Kingdom", at = { 2525, 3165 }, radius = 25 },
    { name = "Gu'Tanoth", subtitle = "Feldip Hills", sprite = "THAS_SHIELD_FELDIP_HILLS", at = { 2510, 3035 }, radius = 25 },
    -- Asgarnia's coast and islands
    { name = "Entrana", at = { 2834, 3335 }, radius = 40 },
    { name = "Crandor", subtitle = "Destroyed city-state", at = { 2850, 3240 }, radius = 35 },
    { name = "Troll Stronghold", subtitle = "Troll Country", at = { 2840, 3690 }, radius = 30 },
    -- Kharidian Desert
    { name = "Al Kharid", subtitle = "Emirate of Al Kharid", sprite = "THAS_SHIELD_ALKHARID", at = { 3293, 3174 }, radius = 35 },
    { name = "Pollnivneach", subtitle = "City-state", at = { 3359, 2970 }, radius = 30 },
    { name = "Nardah", subtitle = "City-state", at = { 3420, 2915 }, radius = 25 },
    { name = "Sophanem", subtitle = "City-state", at = { 3300, 2780 }, radius = 35 },
    { name = "Bedabin Camp", subtitle = "Bedabin Nomads", at = { 3170, 3030 }, radius = 20 },
    -- Morytania
    { name = "Canifis", sprite = "THAS_SHIELD_CANIFIS", at = { 3493, 3488 }, radius = 25 },
    { name = "Port Phasmatys", at = { 3680, 3480 }, radius = 30 },
    { name = "Darkmeyer", subtitle = "Capital of Morytania", at = { 3615, 3365 }, radius = 40 },
    -- Karamja
    { name = "Shilo Village", subtitle = "City-state", at = { 2852, 2955 }, radius = 25 },
    { name = "Tai Bwo Wannai", subtitle = "City-state", at = { 2790, 3065 }, radius = 25 },
    { name = "Marim", subtitle = "Capital of Ape Atoll", at = { 2760, 2785 }, radius = 40 },
    -- Fremennik Province and its isles
    { name = "Rellekka", subtitle = "City-state", sprite = "THAS_SHIELD_FREMENNIK_PROVENCE", at = { 2660, 3660 }, radius = 40 },
    { name = "Miscellania", subtitle = "City-state", at = { 2535, 3860 }, radius = 35 },
    { name = "Etceteria", subtitle = "City-state", at = { 2610, 3875 }, radius = 30 },
    { name = "Jatizso", subtitle = "City-state", at = { 2410, 3810 }, radius = 30 },
    { name = "Neitiznot", subtitle = "City-state", at = { 2335, 3805 }, radius = 25 },
    { name = "Lunar Isle", subtitle = "Home of the Moon Clan", sprite = "THAS_SHIELD_LUNAR_ISLE", at = { 2100, 3910 }, radius = 60 },
    -- Tirannwn
    { name = "Prifddinas", subtitle = "Capital of Tirannwn", sprite = "THAS_SHIELD_ELF_CITY", at = { 2240, 3360 }, radius = 80 },
    { name = "Lletya", at = { 2335, 3170 }, radius = 20 },
    -- Underground and other realms
    { name = "Keldagrim", subtitle = "Capital of the Dwarven Realm", at = { 2900, 10200 }, radius = 70 },
    { name = "Dorgesh-Kaan", subtitle = "City of the Dorgeshuun", at = { 2720, 5350 }, radius = 60 },
    { name = "Zanaris", subtitle = "Realm of the fairies", at = { 2412, 4434 }, radius = 50 },
}

---@type WorldKingdom[]
world_areas.kingdoms = {
    { name = "Misthalin", bounds = { { 3045, 3136, 3269, 3519 }, { 3270, 3320, 3390, 3519 } } },
    { name = "Asgarnia", bounds = { { 2830, 3136, 3044, 3519 }, { 2830, 3520, 2943, 3600 } } },
    -- Before Kandarin, whose rectangle reaches over it.
    { name = "Karamja", sprite = "THAS_SHIELD_KARAMJA", bounds = { { 2690, 2880, 2990, 3135 } } },
    { name = "Kandarin", bounds = { { 2390, 2900, 2829, 3600 } } },
    { name = "The Wilderness", sprite = "THAS_SHIELD_WILDERNESS_VOLCANO", bounds = { { 2944, 3520, 3392, 3968 } } },
    { name = "Morytania", bounds = { { 3391, 3150, 3900, 3600 } } },
    { name = "Kharidian Desert", bounds = { { 3270, 2700, 3500, 3319 }, { 3150, 2700, 3269, 3135 } } },
    { name = "Fremennik Province", sprite = "THAS_SHIELD_FREMENNIK_PROVENCE", bounds = { { 2560, 3601, 2830, 3800 }, { 2300, 3750, 2700, 3920 } } },
    { name = "Tirannwn", sprite = "THAS_SHIELD_TIRANNWN", bounds = { { 2100, 3050, 2389, 3450 } } },
}

---@param x integer
---@param z integer
---@param bounds integer[]
---@return boolean
local function inside(x, z, bounds)
    return x >= bounds[1] and z >= bounds[2] and x <= bounds[3] and z <= bounds[4]
end

-- The town the tile is in: of the towns whose circle it's inside, the one
-- whose middle is nearest. nil outside every town.
---@param x integer
---@param z integer
---@return WorldTown?
function world_areas.town_at(x, z)
    local nearest, nearest_distance
    for _, town in ipairs(world_areas.towns) do
        local distance = math.sqrt((x - town.at[1]) ^ 2 + (z - town.at[2]) ^ 2)
        if distance <= town.radius and (not nearest_distance or distance < nearest_distance) then
            nearest, nearest_distance = town, distance
        end
    end
    return nearest
end

-- Whether the tile is within the town's radius, made bigger or smaller by
-- scale (1 is the town itself).
---@param town WorldTown
---@param x integer
---@param z integer
---@param scale number
---@return boolean
function world_areas.is_near_town(town, x, z, scale)
    local radius = town.radius * scale
    return (x - town.at[1]) ^ 2 + (z - town.at[2]) ^ 2 <= radius ^ 2
end

-- The first area in the list with a rectangle the tile is in.
---@generic Area : WorldKingdom|WorldPlace
---@param areas Area[]
---@param x integer
---@param z integer
---@return Area?
local function first_containing(areas, x, z)
    for _, area in ipairs(areas) do
        for _, bounds in ipairs(area.bounds) do
            if inside(x, z, bounds) then
                return area
            end
        end
    end
    return nil
end

-- The place the tile is in, or nil outside every place.
---@param x integer
---@param z integer
---@return WorldPlace?
function world_areas.place_at(x, z)
    return first_containing(world_areas.places, x, z)
end

-- The kingdom the tile is in, or nil outside every kingdom.
---@param x integer
---@param z integer
---@return WorldKingdom?
function world_areas.kingdom_at(x, z)
    return first_containing(world_areas.kingdoms, x, z)
end

return world_areas
