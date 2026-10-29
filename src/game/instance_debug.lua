-- TEMPORARY: prints the boss instance vars whenever they change, to find out
-- whether instances can be named from them instead of being mapped one by one.
-- BOSS_INSTANCE_CURRENT_BOSS is a plain number (500 at heist 2, 501 at heist 1,
-- from Discord). It's printed both as a struct id and against the
-- BOSS_INSTANCE_UNIQUE_ID of a few boss structs, to see which it is.
local instance_debug = {}

local subscription_name = "area_names_instance_debug"

-- Boss structs to compare the var with, from csvs/Struct.csv.
local known_bosses = {
    "BOSS_INSTANCE_KQ",
    "BOSS_INSTANCE_GWD2_ZAROS",
    "BOSS_INSTANCE_RASIAL_BOSS",
    "BOSS_INSTANCE_ELIDINIS_BOSS",
    "BOSS_INSTANCE_AMASCUT_BOSS_ENCOUNTER",
}

---@type any
local last_player_value
---@type any
local last_client_value

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
        return struct:GetParamValue(param)
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

local function print_known_bosses()
    for _, name in ipairs(known_bosses) do
        local ok, struct = pcall(function() return config.Struct[name] end)
        if ok and struct then
            print(string.format("[Instance debug] %s: unique id %s, boss name %s", name,
                param_of(struct, "BOSS_INSTANCE_UNIQUE_ID"), param_of(struct, "BOSS_INSTANCE_BOSS_NAME")))
        else
            print("[Instance debug] " .. name .. ": couldn't read the struct")
        end
    end
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

local function on_tick()
    local player_value = var.VarPlayer.BOSS_INSTANCE_CURRENT_BOSS.value
    local client_value = var.VarClient.BOSS_INSTANCE_CURRENT_BOSS_CLIENT.value
    if player_value == last_player_value and client_value == last_client_value then
        return
    end
    last_player_value, last_client_value = player_value, client_value
    print(string.format("[Instance debug] BOSS_INSTANCE_CURRENT_BOSS = %s (%s)", tostring(player_value),
        as_struct(player_value)))
    print(string.format("[Instance debug] BOSS_INSTANCE_CURRENT_BOSS_CLIENT = %s (%s)", tostring(client_value),
        as_struct(client_value)))
    print_source()
end

function instance_debug.start()
    print_known_bosses()
    Event.ServerLogic.Subscribe(subscription_name, on_tick)
end

function instance_debug.stop()
    Event.ServerLogic.Unsubscribe(subscription_name)
    last_player_value, last_client_value = nil, nil
end

return instance_debug
