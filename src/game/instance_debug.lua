-- TEMPORARY: prints the boss instance vars whenever they change, to find out
-- whether instances can be named from them instead of being mapped one by one.
-- BOSS_INSTANCE_CURRENT_BOSS is a plain number (500 at heist 2, 501 at heist 1,
-- from Discord). It's printed both as a struct id and against the
-- BOSS_INSTANCE_UNIQUE_ID of every boss struct, to see which it is (it isn't).
-- From Discord: it's the boss's BSLAY_ID (Boss Slayer / Reaper task id), so
-- every struct named BSLAY_* that has one is printed once at startup, and the
-- var is shown with the BSLAY_NAME it matches.
-- Also prints the health bar's struct (ACTIVITY_PROGRESS_BAR_ACTIVE_STRUCT,
-- from Discord: set on the same tick as a boss encounter starts) with its name
-- and area params, and the bar's name client var, whenever they change.
-- Also prints, each game tick, when the player goes in or out of an instance,
-- and in one, whenever the area it resolves to changes.
local world_areas = require("src/game/world_areas")
local world_tracker = require("src/tracker/world_tracker")

local instance_debug = {}

local subscription_name = "area_names_instance_debug"

-- The ids of every struct named BSLAY_*, from csvs/Struct.csv.
local boss_slayer_struct_ids = {
    26, 524, 931, 3025, 3439, 3523, 3705, 3706, 3708, 4414, 4415, 4416, 4555, 4556, 4557, 7089,
    7230, 15426, 15427, 24319, 24322, 24975, 25715, 25716, 25717, 25718, 25719, 25720, 26417, 26432,
    26433, 26434, 26435, 26436, 26437, 26530, 26535, 26536, 26537, 26538, 26539, 28039, 28040,
    28041, 28042, 28043, 28044, 28045, 28046, 28047, 28048, 28105, 28242, 28243, 28244, 28245,
    28246, 28509, 28641, 28642, 28643, 28644, 28645, 28646, 28647, 28648, 28649, 28650, 28651,
    28652, 28653, 28654, 28655, 28656, 28657, 28658, 28659, 28676, 28831, 28832, 28836, 28842,
    28843, 28844, 28845, 28846, 28847, 28863, 28864, 28865, 28866, 28867, 28871, 28872, 28886,
    28887, 28888, 28889, 28890, 28891, 28892, 28930, 28931, 28932, 28933, 28934, 28935, 29099,
    29100, 29101, 29102, 29103, 29104, 29105, 29106, 29107, 29108, 29109, 29110, 29111, 29185,
    29186, 29187, 29341, 29342, 29343, 30473, 30508, 30560, 30561, 30562, 30563, 30564, 30565,
    30566, 30567, 30568, 30569, 30570, 30571, 30572, 30573, 30574, 30575, 30576, 30577, 30578,
    30579, 30580, 30581, 30582, 30583, 30584, 30585, 30586, 30587, 30588, 30589, 30590, 30591,
    30592, 30593, 30594, 30595, 30596, 30597, 30598, 30599, 30600, 30601, 30602, 30603, 30604,
    30605, 30606, 30607, 30608, 30609, 30610, 30611, 30612, 30613, 30614, 30615, 30616, 30617,
    30618, 30619, 30620, 30621, 30622, 30623, 30624, 30625, 30626, 30627, 30628, 30629, 30630,
    30631, 30632, 30633, 30634, 30635, 30636, 30637, 30638, 30639, 30640, 30641, 30642, 30643,
    30644, 30645, 30646, 30648, 30649, 30650, 30651, 30652, 30653, 30654, 30655, 30656, 30657,
    30658, 30659, 30660, 30661, 30662, 30663, 30664, 30665, 30666, 30667, 30668, 30669, 30670,
    30671, 30672, 30673, 30674, 30675, 30676, 30677, 30678, 30679, 30680, 30681, 30682, 30683,
    30684, 30685, 30686, 30687, 30688, 30689, 30690, 30691, 30692, 30693, 30694, 30695, 30696,
    30697, 30698, 30699, 30700, 30701, 30702, 30703, 30704, 30705, 30706, 30707, 30708, 30709,
    30710, 30711, 30712, 30713, 30714, 30715, 30717, 30718, 30719, 30720, 30721, 30722, 30723,
    30724, 30725, 30726, 30727, 30728, 30729, 30730, 30731, 30732, 30733, 30734, 30735, 30823,
    30833, 31376, 31377, 31378, 31575, 31576, 31577, 31578, 31579, 31580, 31581, 31582, 31987,
    31988, 32140, 32141, 32193, 32454, 33192, 33193, 33232, 33233, 33234, 33235, 33312, 33313,
    33314, 33315, 33373, 33374, 33557, 33558, 33559, 33560, 33561, 33562, 33563, 33564, 33565,
    33566, 33567, 33568, 33569, 33570, 33571, 33572, 33573, 33574, 33575, 33576, 33577, 33578,
    33579, 33580, 33581, 33583, 33584, 33585, 33586, 33587, 33588, 33589, 33590, 33591, 33592,
    33593, 33594, 33595, 33596, 33597, 33598, 33599, 33600, 33601, 33602, 33603, 33604, 33605,
    33606, 33607, 33608, 33609, 33610, 33611, 33612, 33613, 33614, 33615, 33616, 33617, 33618,
    33661, 33684, 33685, 33686, 33687, 33688, 33889, 33915, 33920, 35091, 35303, 35312, 35313,
    35367, 35394, 35395, 35396, 35397, 35398, 35399, 35400, 35401, 35402, 35454, 35455, 35456,
    35457, 35458, 35459, 35460, 35461, 35462, 35463, 35464, 35465, 35466, 35467, 35468, 35469,
    35470, 35471, 35472, 35473, 35474, 35476, 35477, 35478, 35479, 35480, 35481, 35482, 35483,
    35484, 35485, 35486, 35487, 35488, 35489, 35490, 35491, 35492, 35493, 35494, 35495, 37612,
    40120, 40150, 40157, 40158, 40159, 40354, 40355, 40356, 40357, 40358, 40359, 40360, 40361,
    40362, 40397, 40398, 40399, 40570, 40571, 40572, 40945, 40946, 40947, 45006, 45007, 45008,
    45038, 45051, 45061, 45410, 45411, 45412, 45413, 45414, 45415, 45416, 45417, 45455, 45586,
    45587, 45588, 45589, 45590, 45591, 45592, 45611, 45726, 45781, 45782, 45783, 45784, 45785,
    45786, 45787, 45788, 45789, 45810, 46257, 46290, 47461, 47462, 47891, 48463, 48464, 49090,
    49820, 49821, 49822, 49823, 49824, 49885, 49991, 49992, 49993, 50088, 50089, 50090, 50205,
    50235, 51140, 51836, 52079, 52661, 53047, 53048,
}

---@type any
local last_player_value
---@type any
local last_client_value

-- A param's value as text. Coords are shown as x, z, level when they have them.
---@param value any
---@return string
local function describe(value)
    local ok, text = pcall(function()
        if type(value) == "userdata" and value.x and value.z then
            return string.format("%d, %d, level %s", value.x, value.z, tostring(value.level))
        end
        return tostring(value)
    end)
    return ok and text or tostring(value)
end

-- A struct's param, or a note on why it couldn't be read.
---@param struct StructType
---@param param_name string
---@return string
local function param_of(struct, param_name)
    local ok, value = pcall(function()
        local param = config.Param[param_name]
        if not struct:HasParam(param) then
            return "(none)"
        end
        return describe(struct:GetParamValue(param))
    end)
    return ok and tostring(value) or ("(error: " .. tostring(value) .. ")")
end

-- What the value would be if it were a struct id.
---@param value any
---@return string
local function as_struct(value)
    if type(value) ~= "number" or value <= 0 then
        return "not a struct"
    end
    local ok, struct = pcall(config.Struct.FromID, value)
    if not ok or struct == nil then
        return "no struct with that id"
    end
    return string.format("struct %s, boss name %s", struct.configName,
        param_of(struct, "BOSS_INSTANCE_BOSS_NAME"))
end

-- The bosses' BSLAY_NAMEs by their BSLAY_ID, filled at startup.
---@type table<string, string[]>
local bosses_by_slayer_id = {}

local function print_boss_slayer_ids()
    local found = 0
    for _, struct_id in ipairs(boss_slayer_struct_ids) do
        local ok, struct = pcall(config.Struct.FromID, struct_id)
        if ok and struct and param_of(struct, "BSLAY_ID") ~= "(none)" then
            local slayer_id = param_of(struct, "BSLAY_ID")
            local name = param_of(struct, "BSLAY_NAME")
            bosses_by_slayer_id[slayer_id] = bosses_by_slayer_id[slayer_id] or {}
            table.insert(bosses_by_slayer_id[slayer_id], name)
            found = found + 1
            print(string.format("[Instance debug] BSLAY_ID %s: %s (struct %s %s)", slayer_id, name, tostring(struct_id),
                struct.configName))
        end
    end
    print(string.format("[Instance debug] %d of %d BSLAY_* structs have a BSLAY_ID", found, #boss_slayer_struct_ids))
end

-- The bosses whose BSLAY_ID is the value, if any.
---@param value any
---@return string
local function as_slayer_id(value)
    local names = bosses_by_slayer_id[tostring(value)]
    return names and ("BSLAY_ID of " .. table.concat(names, ", ")) or "no boss has that BSLAY_ID"
end

local function print_source()
    local player = Player.GetEntity()
    local tile = player and player.coordGrid
    if tile and World.IsRegion() then
        local source = World.GetRegionSourceForCoordGrid(tile)
        print(string.format("[Instance debug]   in an instance at %d, %d, copied from %s", tile.x, tile.z,
            source and string.format("%d, %d", source.x, source.z) or "nowhere"))
    end
end

---@type boolean?
local last_in_instance
---@type string?
local last_area

-- The area the plugin finds at a tile: place, town and kingdom.
---@param x integer
---@param z integer
---@return string
local function areas_at(x, z)
    local place = world_areas.place_at(x, z)
    local town = world_areas.town_at(x, z)
    local kingdom = world_areas.kingdom_at(x, z)
    return string.format("place %s, town %s, kingdom %s", place and place.name or "(none)",
        town and town.name or "(none)", kingdom and kingdom.name or "(none)")
end

local function print_instance_changes()
    local player = Player.GetEntity()
    local tile = player and player.coordGrid
    if not tile or not World.IsAvailable() then
        return
    end
    local in_instance = World.IsRegion()
    if in_instance ~= last_in_instance then
        print(string.format("[Instance debug] %s an instance, player at %d, %d",
            in_instance and "Entered" or "Not in", tile.x, tile.z))
        last_in_instance = in_instance
        last_area = nil
    end
    if not in_instance then
        return
    end
    local x, z = world_tracker.player_tile()
    if not x then
        return
    end
    local area = areas_at(x, z)
    if area ~= last_area then
        local source = World.GetRegionSourceForCoordGrid(tile)
        print(string.format("[Instance debug]   at %d, %d, source %s, counted as %d, %d: %s", tile.x, tile.z,
            source and string.format("%d, %d", source.x, source.z) or "none", x, z, area))
        last_area = area
    end
end

---@type any
local last_bar_struct
---@type any
local last_bar_name

local function print_progress_bar_changes()
    local bar_struct = var.VarPlayer.ACTIVITY_PROGRESS_BAR_ACTIVE_STRUCT.value
    local bar_name = var.VarClient.ACTIVITY_PROGRESS_BAR_ACTIVE_NAME.value
    if bar_struct == last_bar_struct and bar_name == last_bar_name then
        return
    end
    last_bar_struct, last_bar_name = bar_struct, bar_name
    local details = "not a struct"
    if type(bar_struct) == "number" and bar_struct > 0 then
        local ok, struct = pcall(config.Struct.FromID, bar_struct)
        if ok and struct then
            details = string.format("struct %s, name %s, area %s", struct.configName,
                param_of(struct, "ACTIVITY_PROGRESS_BAR_NAME"), param_of(struct, "ACTIVITY_PROGRESS_BAR_AREA"))
        else
            details = "no struct with that id"
        end
    end
    print(string.format("[Instance debug] ACTIVITY_PROGRESS_BAR_ACTIVE_STRUCT = %s (%s), ACTIVE_NAME = %s",
        tostring(bar_struct), details, tostring(bar_name)))
end

local function on_tick()
    print_instance_changes()
    print_progress_bar_changes()
    local player_value = var.VarPlayer.BOSS_INSTANCE_CURRENT_BOSS.value
    local client_value = var.VarClient.BOSS_INSTANCE_CURRENT_BOSS_CLIENT.value
    if player_value == last_player_value and client_value == last_client_value then
        return
    end
    last_player_value, last_client_value = player_value, client_value
    print(string.format("[Instance debug] BOSS_INSTANCE_CURRENT_BOSS = %s (%s; %s)", tostring(player_value),
        as_struct(player_value), as_slayer_id(player_value)))
    print(string.format("[Instance debug] BOSS_INSTANCE_CURRENT_BOSS_CLIENT = %s (%s; %s)", tostring(client_value),
        as_struct(client_value), as_slayer_id(client_value)))
    print_source()
end

function instance_debug.start()
    print_boss_slayer_ids()
    Event.ServerLogic.Subscribe(subscription_name, on_tick)
end

function instance_debug.stop()
    Event.ServerLogic.Unsubscribe(subscription_name)
    last_player_value, last_client_value = nil, nil
    last_in_instance, last_area = nil, nil
    bosses_by_slayer_id = {}
    last_bar_struct, last_bar_name = nil, nil
end

return instance_debug
