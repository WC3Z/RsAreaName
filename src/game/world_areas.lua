-- The named places in the game world: places outside the towns and kingdoms
-- (like War's Retreat, or where an instance is copied from), towns, each an
-- outline or a circle around its middle, and kingdoms. Places and kingdoms
-- are an outline or one or more rectangles. All positions are world tiles (CoordGrid.x and
-- CoordGrid.z); a map square is 64 of them.
local world_areas = {}

---@class WorldTown
---@field name string
---@field subtitle? string
---@field sprite? string A sprite shown above the name, as its name in id.Sprite
---@field points? integer[][] Its outline: the corners in order, each { world tile x, world tile z }. Towns without one are a circle
---@field at? integer[] { world tile x, world tile z } of the circle's middle
---@field radius? integer The circle's radius, in tiles

---@class WorldKingdom
---@field name string
---@field sprite? string A sprite shown above the name, as its name in id.Sprite
---@field bounds? integer[][] Rectangles, each { min x, min z, max x, max z } in world tiles (both ends included)
---@field points? integer[][] Its outline instead of rectangles, like a town's

---@class WorldPlace
---@field name string
---@field subtitle? string
---@field sprite? string A sprite shown above the name, as its name in id.Sprite
---@field bounds? integer[][] Rectangles, like a kingdom's
---@field points? integer[][] Its outline instead of rectangles, like a town's

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
    -- Outline from the wiki's Grand Exchange page.
    { name = "Grand Exchange", points = { { 3138, 3472 }, { 3143, 3467 }, { 3148, 3467 }, { 3151, 3464 }, { 3179, 3464 }, { 3182, 3467 }, { 3188, 3475 }, { 3191, 3478 }, { 3191, 3496 }, { 3197, 3502 }, { 3197, 3503 }, { 3200, 3506 }, { 3190, 3518 }, { 3138, 3513 }, { 3138, 3494 }, { 3139, 3493 }, { 3139, 3486 }, { 3138, 3485 } } },
    { name = "Edgeville", sprite = "THAS_SHIELD_EDGEVILLE", at = { 3093, 3493 }, radius = 25 },
    { name = "Barbarian Village", at = { 3082, 3420 }, radius = 20 },
    { name = "Wizards' Tower", at = { 3104, 3160 }, radius = 20 },
    -- Asgarnia
    { name = "Falador", sprite = "THAS_SHIELD_FALADOR", subtitle = "Capital of Asgarnia", at = { 2965, 3380 }, radius = 45 },
    -- Outline from the wiki's Falador Park page.
    { name = "Falador Park", subtitle = "Falador", points = { { 3023, 3388 }, { 3027, 3384 }, { 3032, 3384 }, { 3032, 3381 }, { 3030, 3381 }, { 3030, 3378 }, { 3032, 3378 }, { 3032, 3375 }, { 3027, 3375 }, { 3025, 3373 }, { 3025, 3371 }, { 3022, 3368 }, { 3020, 3368 }, { 3019, 3367 }, { 3014, 3367 }, { 3012, 3369 }, { 3002, 3369 }, { 2998, 3373 }, { 2994, 3373 }, { 2991, 3376 }, { 2990, 3376 }, { 2986, 3380 }, { 2983, 3380 }, { 2981, 3382 }, { 2981, 3389 }, { 2984, 3392 }, { 3002, 3392 }, { 3005, 3389 } } },
    { name = "Port Sarim", sprite = "THAS_SHIELD_PORTSARIM", at = { 3023, 3208 }, radius = 30 },
    { name = "Rimmington", at = { 2957, 3214 }, radius = 25 },
    { name = "Taverley", sprite = "THAS_SHIELD_TAVERLY", at = { 2894, 3456 }, radius = 30 },
    { name = "Burthorpe", sprite = "THAS_SHIELD_BURTHORPE", at = { 2899, 3544 }, radius = 30 },
    -- Kandarin
    { name = "Catherby", sprite = "THAS_SHIELD_CATHERBY", at = { 2813, 3447 }, radius = 30 },
    { name = "Seers' Village", sprite = "THAS_SHIELD_SEERS", at = { 2726, 3485 }, radius = 30 },
    { name = "East Ardougne", sprite = "THAS_SHIELD_ARDOUNGE", subtitle = "Capital of Kandarin", at = { 2662, 3305 }, radius = 45 },
    { name = "Yanille", sprite = "THAS_SHIELD_YANILLE", at = { 2606, 3093 }, radius = 30 },
    -- Outline from the wiki's West Ardougne page.
    { name = "West Ardougne", subtitle = "Capital of West Kandarin", points = { { 2434, 3325 }, { 2462, 3325 }, { 2462, 3337 }, { 2559, 3337 }, { 2559, 3264 }, { 2509, 3264 }, { 2509, 3279 }, { 2459, 3279 }, { 2459, 3305 }, { 2434, 3305 } } },
    { name = "Gnome Stronghold", subtitle = "Gnomish Kingdom", at = { 2460, 3440 }, radius = 45 },
    { name = "Tree Gnome Village", subtitle = "Gnomish Kingdom", at = { 2525, 3165 }, radius = 25 },
    { name = "Gu'Tanoth", subtitle = "Feldip Hills", sprite = "THAS_SHIELD_FELDIP_HILLS", at = { 2510, 3035 }, radius = 25 },
    { name = "Eagles' Peak", sprite = "THAS_SHIELD_EAGLES_PEAK", at = { 2606, 3264 }, radius = 30 },
    { name = "Port Khazard", at = { 2654, 3161 }, radius = 25 },
    { name = "Castle Wars", at = { 2407, 3103 }, radius = 25 },
    -- Asgarnia's coast and islands
    { name = "Entrana", at = { 2834, 3335 }, radius = 40 },
    { name = "Crandor", subtitle = "Destroyed city-state", at = { 2850, 3240 }, radius = 35 },
    { name = "Troll Stronghold", subtitle = "Troll Country", at = { 2840, 3690 }, radius = 30 },
    -- Kharidian Desert
    { name = "Al Kharid", subtitle = "Emirate of Al Kharid", sprite = "THAS_SHIELD_ALKHARID", at = { 3293, 3174 }, radius = 35 },
    { name = "Pollnivneach", subtitle = "City-state", at = { 3359, 2970 }, radius = 30 },
    { name = "Nardah", subtitle = "City-state", at = { 3420, 2915 }, radius = 25 },
    { name = "Sophanem", subtitle = "City-state", at = { 3305, 2730 }, radius = 35 },
    { name = "Port District", subtitle = "Menaphos", sprite = "THAS_SHIELD_MENAPHOS", at = { 3185, 2655 }, radius = 40 },
    { name = "Imperial District", subtitle = "Menaphos", sprite = "THAS_SHIELD_MENAPHOS", at = { 3144, 2729 }, radius = 40 },
    { name = "Merchant District", subtitle = "Menaphos", sprite = "THAS_SHIELD_MENAPHOS", at = { 3214, 2783 }, radius = 35 },
    { name = "Worker District", subtitle = "Menaphos", sprite = "THAS_SHIELD_MENAPHOS", at = { 3156, 2794 }, radius = 35 },
    { name = "Bedabin Camp", subtitle = "Bedabin Nomads", at = { 3170, 3030 }, radius = 20 },
    -- Morytania
    { name = "Canifis", sprite = "THAS_SHIELD_CANIFIS", at = { 3493, 3488 }, radius = 25 },
    { name = "Port Phasmatys", at = { 3680, 3480 }, radius = 30 },
    { name = "Darkmeyer", subtitle = "Capital of Morytania", at = { 3615, 3365 }, radius = 40 },
    { name = "Mort'ton", at = { 3491, 3287 }, radius = 20 },
    { name = "Burgh de Rott", at = { 3504, 3220 }, radius = 25 },
    -- The Wilderness
    { name = "Fort Forinthry", at = { 3305, 3553 }, radius = 30 },
    -- Karamja
    { name = "Brimhaven", at = { 2761, 3183 }, radius = 30 },
    { name = "Musa Point", at = { 2889, 3178 }, radius = 20 },
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
    -- Islands out at sea
    { name = "Mos Le'Harmless", subtitle = "Eastern Sea", sprite = "RS3_WORLDMAP_REGION_SHIELD_MOSLEHARMLESS", at = { 3748, 2994 }, radius = 55 },
    { name = "Harmony Island", subtitle = "Eastern Sea", at = { 3808, 2855 }, radius = 25 },
    { name = "Dragontooth Island", subtitle = "Eastern Sea", at = { 3806, 3548 }, radius = 20 },
    { name = "Crash Island", subtitle = "Unquiet Ocean", at = { 2914, 2721 }, radius = 25 },
    { name = "Void Knights' Outpost", subtitle = "Southern Sea", at = { 2657, 2618 }, radius = 35 },
    { name = "Waterbirth Island", subtitle = "Northern Sea", at = { 2528, 3740 }, radius = 30 },
    { name = "Iceberg", subtitle = "Lunar Sea", at = { 2675, 4020 }, radius = 30 },
    { name = "Pirates' Cove", subtitle = "Lunar Sea", at = { 2207, 3812 }, radius = 25 },
    -- Havenhythe. The wiki and the world map show it moved by 704, 1792 from its real
    -- tiles, which these are. Where its places are is from Better World Map's labels.
    { name = "Wendlewick", at = { 3480, 1553 }, radius = 40 },
    { name = "Marigold Farm", at = { 3552, 1493 }, radius = 15 },
    { name = "Shrine of Inanna", at = { 3556, 1423 }, radius = 15 },
    { name = "Eastfold Farm", at = { 3619, 1439 }, radius = 15 },
    { name = "Highweald Forest", at = { 3506, 1658 }, radius = 35 },
    { name = "Hollow Hill", at = { 3631, 1649 }, radius = 25 },
    { name = "Amberfell", at = { 3738, 1574 }, radius = 30 },
    { name = "Moonrise Dig Site", at = { 3730, 1654 }, radius = 20 },
    { name = "Moonsylvar Wood", at = { 3734, 1455 }, radius = 35 },
    { name = "Berylbrook", at = { 3859, 1556 }, radius = 25 },
    { name = "Heathervein", at = { 3866, 1678 }, radius = 25 },
    { name = "Linbog Village", subtitle = "Fenmoor", at = { 3881, 1498 }, radius = 20 },
    { name = "Fenmoor", at = { 3921, 1429 }, radius = 60 },
    { name = "Shuruk-Ba", at = { 4043, 1604 }, radius = 40 },
    -- Tirannwn
    -- Its real tiles, which the world map shows moved to inside Tirannwn.
    { name = "Prifddinas", subtitle = "Capital of Tirannwn", sprite = "THAS_SHIELD_ELF_CITY", points = { { 4480, 2560 }, { 4671, 2560 }, { 4671, 2815 }, { 4480, 2815 } } },
    { name = "Lletya", at = { 2335, 3170 }, radius = 20 },
    -- Underground and other realms
    { name = "Keldagrim", subtitle = "Capital of the Dwarven Realm", at = { 2900, 10200 }, radius = 70 },
    { name = "Dorgesh-Kaan", subtitle = "City of the Dorgeshuun", at = { 2720, 5350 }, radius = 60 },
    { name = "Zanaris", subtitle = "Realm of the fairies", at = { 2412, 4434 }, radius = 50 },
}

---@type WorldKingdom[]
world_areas.kingdoms = {
    -- Traced on Better World Map's map.
    { name = "Karamja", sprite = "THAS_SHIELD_KARAMJA", points = { { 2987, 2878 }, { 3020, 3020 }, { 3006, 3089 }, { 2950, 3115 }, { 2979, 3141 }, { 2976, 3172 }, { 2886, 3222 }, { 2809, 3232 }, { 2742, 3265 }, { 2695, 3225 }, { 2691, 3183 }, { 2697, 3130 }, { 2757, 2874 } } },
    -- Outline from the wiki's Misthalin page.
    { name = "Misthalin", points = { { 3066, 3522 }, { 3273, 3522 }, { 3273, 3570 }, { 3281, 3578 }, { 3329, 3578 }, { 3337, 3570 }, { 3362, 3570 }, { 3368, 3579 }, { 3391, 3579 }, { 3391, 3536 }, { 3403, 3528 }, { 3403, 3517 }, { 3419, 3508 }, { 3434, 3486 }, { 3398, 3427 }, { 3398, 3326 }, { 3266, 3326 }, { 3268, 3211 }, { 3257, 3176 }, { 3242, 3140 }, { 3168, 3120 }, { 3100, 3120 }, { 3055, 3147 }, { 3055, 3176 }, { 3066, 3186 } } },
    -- Traced on Better World Map's map.
    { name = "Asgarnia", points = { { 3006, 3098 }, { 2968, 3116 }, { 2988, 3153 }, { 2985, 3173 }, { 2978, 3186 }, { 2955, 3187 }, { 2916, 3208 }, { 2858, 3316 }, { 2791, 3309 }, { 2793, 3379 }, { 2829, 3401 }, { 2866, 3429 }, { 2868, 3465 }, { 2860, 3480 }, { 2867, 3494 }, { 2866, 3508 }, { 2878, 3527 }, { 2836, 3532 }, { 2835, 3556 }, { 2835, 3588 }, { 2867, 3575 }, { 2899, 3577 }, { 2917, 3580 }, { 2934, 3573 }, { 2950, 3571 }, { 2947, 3556 }, { 2944, 3554 }, { 2946, 3552 }, { 2949, 3541 }, { 2952, 3534 }, { 2956, 3533 }, { 2958, 3531 }, { 2957, 3529 }, { 2955, 3527 }, { 2953, 3529 }, { 2939, 3523 }, { 2963, 3525 }, { 2980, 3536 }, { 3001, 3527 }, { 3011, 3528 }, { 3009, 3538 }, { 3011, 3543 }, { 3012, 3559 }, { 3005, 3561 }, { 3000, 3558 }, { 2997, 3562 }, { 3000, 3566 }, { 3000, 3575 }, { 2998, 3577 }, { 2998, 3582 }, { 3003, 3584 }, { 3005, 3581 }, { 3029, 3580 }, { 3032, 3584 }, { 3037, 3581 }, { 3038, 3576 }, { 3035, 3575 }, { 3034, 3545 }, { 3037, 3540 }, { 3038, 3534 }, { 3036, 3533 }, { 3034, 3520 }, { 3064, 3522 }, { 3065, 3187 }, { 3054, 3178 }, { 3054, 3145 } } },
    -- Traced on Better World Map's map.
    { name = "Kandarin", points = { { 2780, 3584 }, { 2681, 3601 }, { 2639, 3591 }, { 2566, 3582 }, { 2180, 3766 }, { 2110, 3706 }, { 2150, 3592 }, { 2278, 3456 }, { 2348, 3445 }, { 2340, 3394 }, { 2354, 3350 }, { 2376, 3337 }, { 2399, 3332 }, { 2433, 3325 }, { 2397, 3312 }, { 2402, 3273 }, { 2427, 3261 }, { 2432, 3220 }, { 2418, 3148 }, { 2361, 3143 }, { 2362, 3084 }, { 2329, 3075 }, { 2321, 3059 }, { 2332, 3035 }, { 2368, 3025 }, { 2444, 3032 }, { 2451, 3067 }, { 2503, 3065 }, { 2523, 3067 }, { 2539, 3051 }, { 2552, 3058 }, { 2551, 3062 }, { 2545, 3060 }, { 2542, 3066 }, { 2548, 3067 }, { 2558, 3057 }, { 2563, 3047 }, { 2575, 3045 }, { 2584, 3037 }, { 2695, 3067 }, { 2690, 3162 }, { 2686, 3226 }, { 2746, 3271 }, { 2814, 3239 }, { 2800, 3296 }, { 2787, 3309 }, { 2790, 3383 }, { 2860, 3432 }, { 2863, 3464 }, { 2855, 3481 }, { 2864, 3494 }, { 2865, 3512 }, { 2871, 3524 }, { 2826, 3529 }, { 2799, 3545 } } },
    -- Traced on Better World Map's map. Before the Wilderness and Morytania, whose
    -- rectangles reach over its edges.
    { name = "Daemonheim", points = { { 3374, 3606 }, { 3488, 3587 }, { 3539, 3617 }, { 3533, 3808 }, { 3384, 3801 }, { 3380, 3757 }, { 3390, 3743 }, { 3390, 3726 }, { 3376, 3720 }, { 3377, 3712 }, { 3388, 3700 }, { 3383, 3690 }, { 3384, 3674 }, { 3379, 3663 }, { 3388, 3645 }, { 3371, 3620 } } },
    -- Traced on Better World Map's map.
    { name = "The Wilderness", sprite = "THAS_SHIELD_WILDERNESS_VOLCANO", points = { { 2955, 3527 }, { 2985, 3537 }, { 3008, 3531 }, { 2991, 3561 }, { 2994, 3588 }, { 3033, 3594 }, { 3047, 3575 }, { 3049, 3535 }, { 3096, 3547 }, { 3105, 3565 }, { 3144, 3533 }, { 3164, 3543 }, { 3213, 3536 }, { 3257, 3548 }, { 3266, 3540 }, { 3272, 3575 }, { 3276, 3585 }, { 3333, 3581 }, { 3350, 3577 }, { 3360, 3574 }, { 3378, 3602 }, { 3367, 3623 }, { 3385, 3643 }, { 3379, 3663 }, { 3381, 3701 }, { 3376, 3720 }, { 3388, 3730 }, { 3386, 3748 }, { 3372, 3774 }, { 3383, 3824 }, { 3504, 3954 }, { 3374, 4013 }, { 2955, 3997 }, { 2944, 3945 }, { 2946, 3858 }, { 2939, 3780 }, { 2947, 3765 }, { 2953, 3678 }, { 2961, 3661 }, { 2950, 3556 } } },
    -- Traced on Better World Map's map.
    { name = "Morytania", points = { { 3423, 3200 }, { 3422, 3271 }, { 3414, 3288 }, { 3421, 3328 }, { 3400, 3365 }, { 3405, 3432 }, { 3416, 3462 }, { 3425, 3474 }, { 3424, 3501 }, { 3392, 3540 }, { 3391, 3590 }, { 3412, 3609 }, { 3487, 3588 }, { 3693, 3578 }, { 3883, 3187 }, { 3811, 3082 }, { 3485, 3159 }, { 3458, 3194 } } },
    -- Traced on Better World Map's map.
    { name = "Kharidian Desert", points = { { 3256, 3164 }, { 3269, 3211 }, { 3267, 3324 }, { 3398, 3325 }, { 3415, 3304 }, { 3412, 3282 }, { 3420, 3265 }, { 3422, 3200 }, { 3462, 3181 }, { 3514, 3114 }, { 3534, 3007 }, { 3488, 2942 }, { 3413, 2634 }, { 3229, 2500 }, { 3125, 2542 }, { 2968, 2704 }, { 3050, 2931 }, { 3205, 3121 }, { 3251, 3137 } } },
    -- Outline from the wiki's Fremennik Province page.
    { name = "Fremennik Province", sprite = "THAS_SHIELD_FREMENNIK_PROVENCE", points = { { 2302, 3925 }, { 2750, 3925 }, { 2750, 3715 }, { 2805, 3715 }, { 2805, 3632 }, { 2785, 3585 }, { 2575, 3585 }, { 2470, 3615 }, { 2470, 3770 }, { 2300, 3770 } } },
    -- Traced on Better World Map's map. Both are moved on the world map; these are
    -- their real tiles.
    { name = "Havenhythe", points = { { 3558, 1298 }, { 3434, 1367 }, { 3349, 1498 }, { 3362, 1654 }, { 3399, 1809 }, { 3430, 1849 }, { 3609, 1829 }, { 3727, 1781 }, { 3838, 1782 }, { 3866, 1842 }, { 4002, 1853 }, { 4083, 1804 }, { 4143, 1763 }, { 4141, 1511 }, { 4111, 1491 }, { 4030, 1314 }, { 3761, 1285 }, { 3625, 1281 } } },
    { name = "Anachronia", points = { { 5694, 2108 }, { 5699, 2118 }, { 5739, 2171 }, { 5754, 2343 }, { 5745, 2430 }, { 5715, 2505 }, { 5526, 2602 }, { 5342, 2560 }, { 5252, 2545 }, { 5126, 2420 }, { 5131, 2295 }, { 5338, 2073 }, { 5426, 2058 }, { 5664, 2088 } } },
    -- Traced on Better World Map's map.
    { name = "Tirannwn", sprite = "THAS_SHIELD_TIRANNWN", points = { { 2283, 3468 }, { 2158, 3483 }, { 2101, 3417 }, { 2108, 3067 }, { 2200, 3008 }, { 2309, 3015 }, { 2320, 3062 }, { 2333, 3079 }, { 2360, 3082 }, { 2361, 3148 }, { 2407, 3168 }, { 2428, 3204 }, { 2434, 3263 }, { 2399, 3268 }, { 2393, 3314 }, { 2392, 3332 }, { 2377, 3331 }, { 2363, 3331 }, { 2346, 3377 }, { 2343, 3437 } } },
}

---@param x integer
---@param z integer
---@param bounds integer[]
---@return boolean
local function inside(x, z, bounds)
    return x >= bounds[1] and z >= bounds[2] and x <= bounds[3] and z <= bounds[4]
end

-- How far the tile is from the line between two corners, in tiles.
---@param x number
---@param z number
---@param from integer[]
---@param to integer[]
---@return number
local function distance_to_line(x, z, from, to)
    local line_x, line_z = to[1] - from[1], to[2] - from[2]
    local length_squared = line_x ^ 2 + line_z ^ 2
    -- How far along the line the nearest point is, from 0 at `from` to 1 at `to`.
    local along = 0
    if length_squared > 0 then
        along = math.max(0, math.min(1, ((x - from[1]) * line_x + (z - from[2]) * line_z) / length_squared))
    end
    return math.sqrt((x - from[1] - along * line_x) ^ 2 + (z - from[2] - along * line_z) ^ 2)
end

-- Whether the tile is inside the outline: a line from it going +x crosses the
-- outline an odd number of times.
---@param points integer[][]
---@param x number
---@param z number
---@return boolean
local function inside_outline(points, x, z)
    local inside_it = false
    local previous = points[#points]
    for _, point in ipairs(points) do
        if (point[2] > z) ~= (previous[2] > z) then
            local crossing_x = point[1] + (z - point[2]) * (previous[1] - point[1]) / (previous[2] - point[2])
            if x < crossing_x then
                inside_it = not inside_it
            end
        end
        previous = point
    end
    return inside_it
end

-- How far the tile is outside the town (or any area with an outline), in
-- tiles; 0 or less is inside it. Tiles on the outline count as inside.
---@param town WorldTown|WorldKingdom|WorldPlace
---@param x integer
---@param z integer
---@return number
function world_areas.distance_outside(town, x, z)
    if town.points then
        local nearest = math.huge
        local previous = town.points[#town.points]
        for _, point in ipairs(town.points) do
            nearest = math.min(nearest, distance_to_line(x, z, previous, point))
            previous = point
        end
        return inside_outline(town.points, x, z) and -nearest or nearest
    end
    return math.sqrt((x - town.at[1]) ^ 2 + (z - town.at[2]) ^ 2) - town.radius
end

-- How big each town is, in square tiles, worked out when first needed.
---@type table<WorldTown, number>
local town_sizes = setmetatable({}, { __mode = "k" })

---@param town WorldTown
---@return number
local function size_of(town)
    if town_sizes[town] then
        return town_sizes[town]
    end
    local size
    if town.points then
        -- The shoelace formula.
        local twice_size = 0
        local previous = town.points[#town.points]
        for _, point in ipairs(town.points) do
            twice_size = twice_size + previous[1] * point[2] - point[1] * previous[2]
            previous = point
        end
        size = math.abs(twice_size) / 2
    else
        size = math.pi * town.radius ^ 2
    end
    town_sizes[town] = size
    return size
end

-- The town the tile is in. Where towns overlap, the smallest wins, so the
-- Grand Exchange shows inside Varrock. nil outside every town.
---@param x integer
---@param z integer
---@return WorldTown?
function world_areas.town_at(x, z)
    local smallest
    for _, town in ipairs(world_areas.towns) do
        if world_areas.distance_outside(town, x, z) <= 0 and (not smallest or size_of(town) < size_of(smallest)) then
            smallest = town
        end
    end
    return smallest
end

-- Whether the tile is in the town, or at most `margin` tiles outside it.
---@param town WorldTown
---@param x integer
---@param z integer
---@param margin number In tiles
---@return boolean
function world_areas.is_near_town(town, x, z, margin)
    return world_areas.distance_outside(town, x, z) <= margin
end

-- The first area in the list whose outline or rectangles the tile is in.
---@generic Area : WorldKingdom|WorldPlace
---@param areas Area[]
---@param x integer
---@param z integer
---@return Area?
local function first_containing(areas, x, z)
    for _, area in ipairs(areas) do
        if area.points then
            if world_areas.distance_outside(area, x, z) <= 0 then
                return area
            end
        else
            for _, bounds in ipairs(area.bounds) do
                if inside(x, z, bounds) then
                    return area
                end
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
