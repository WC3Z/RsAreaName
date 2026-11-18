-- Finding the place, kingdom and instance for where the player is.
package.path = "./?.lua;" .. package.path
local world_areas = require("src/game/world_areas")

-- The lookups, on areas made for the test.
local real_places, real_kingdoms = world_areas.places, world_areas.kingdoms
local town = { name = "Town", points = { { 0, 0 }, { 100, 0 }, { 100, 100 }, { 0, 100 } } }
local market = { name = "Market", points = { { 40, 40 }, { 60, 40 }, { 60, 60 }, { 40, 60 } } }
local well = { name = "Well", at = { 200, 200 }, radius = 10 }
local kingdom = { name = "Kingdom", points = { { -50, -50 }, { 300, -50 }, { 300, 300 }, { -50, 300 } } }
local island = { name = "Island", points = { { 1000, 1000 }, { 1100, 1000 }, { 1050, 1100 } } }
world_areas.places = { town, market, well }
world_areas.kingdoms = { island, kingdom }

assert(world_areas.place_at(10, 10) == town, "inside an outline")
assert(world_areas.place_at(50, 50) == market, "where places overlap, the smallest wins")
assert(world_areas.place_at(205, 205) == well, "inside a circle")
assert(world_areas.place_at(215, 200) == nil, "outside the circle")
assert(world_areas.place_at(150, 150) == nil, "outside every place")
assert(world_areas.place_at(0, 50) == town, "on the outline counts as inside")
assert(world_areas.place_at(50, 50, function (place) return place ~= market end) == town,
    "a place that's left out makes way for the bigger one around it")

assert(world_areas.distance_outside(town, 110, 50) == 10, "how far outside an outline's edge")
assert(world_areas.distance_outside(town, 50, 50) == -50, "negative inside: how far from the edge")
assert(world_areas.distance_outside(well, 220, 200) == 10, "how far outside a circle")
assert(world_areas.is_near_place(town, 104, 50, 5), "within the margin of a place")
assert(not world_areas.is_near_place(town, 106, 50, 5), "past the margin")

assert(world_areas.kingdom_at(150, 150) == kingdom, "inside a kingdom's outline")
assert(world_areas.kingdom_at(1050, 1050) == island, "the first kingdom in the list that it's in")
assert(world_areas.kingdom_at(5000, 5000) == nil, "outside every kingdom")

world_areas.places, world_areas.kingdoms = real_places, real_kingdoms

-- Instances by id and by the name on the boss's health bar.
local araxxi = world_areas.instance_with_id(1)
assert(araxxi and araxxi.name == "Araxxi", "an instance by its id")
assert(world_areas.instance_with_id(nil) == nil and world_areas.instance_with_id(-5) == nil, "no instance without a known id")
assert(world_areas.instance_id_with_bar_name("Araxxi") == 1, "by the boss's name")
assert(world_areas.instance_id_with_bar_name("araxxi") == 1, "whatever the capitals")
assert(world_areas.instance_id_with_bar_name("Dagannoth Rex") == 7, "by another name its bar may show")
assert(world_areas.instance_id_with_bar_name("") == nil and world_areas.instance_id_with_bar_name(nil) == nil, "no bar, no instance")
assert(world_areas.instance_id_with_bar_name("Nobody at all") == nil, "an unknown name")
for instance_id, instance in pairs(world_areas.instances) do
    if instance.name:lower():find("^the ") then
        local without_the = instance.name:sub(5)
        local found_id = world_areas.instance_id_with_bar_name(without_the)
        assert(found_id ~= nil and world_areas.instances[found_id].name == instance.name,
            instance.name .. " is found without its \"The\" (instance " .. instance_id .. ")")
        break
    end
end

-- The data itself: every area can be looked up.
for _, place in ipairs(world_areas.places) do
    assert(type(place.name) == "string" and place.name ~= "", "every place has a name")
    if place.points then
        assert(#place.points >= 3, place.name .. "'s outline has at least three corners")
        for _, point in ipairs(place.points) do
            assert(type(point[1]) == "number" and type(point[2]) == "number", place.name .. "'s corners are { x, z }")
        end
    else
        assert(place.at and type(place.at[1]) == "number" and type(place.at[2]) == "number" and type(place.radius) == "number",
            place.name .. " has an outline, or a middle and a radius")
    end
end
for _, kingdom_area in ipairs(world_areas.kingdoms) do
    assert(type(kingdom_area.name) == "string" and kingdom_area.points and #kingdom_area.points >= 3,
        tostring(kingdom_area.name) .. " has a name and an outline")
end
for instance_id, instance in pairs(world_areas.instances) do
    assert(type(instance_id) == "number" and type(instance.name) == "string", "every instance has an id and a name")
end

-- Known spots, to catch a slip in the data.
local varrock_square = world_areas.place_at(3213, 3428)
assert(varrock_square and varrock_square.name == "Varrock", "Varrock's square is in Varrock, not " .. tostring(varrock_square and varrock_square.name))
