-- Which area's title shows for where the player is.
package.path = "./?.lua;" .. package.path
local area_choice = require("src/tracker/area_choice")

local boss = { name = "Boss", subtitle = "Lair" }
local town = { name = "Town", subtitle = "Capital", sprite = "SHIELD" }
local farm = { name = "Farm" }
local realm = { name = "Realm", sprite = "REALM_SHIELD" }
local other_realm = { name = "Other Realm" }
local function shown() return true end
local function hidden() return false end

local area, subtitle = area_choice.newly_entered({ instance = boss, place = town, kingdom = realm }, {}, shown)
assert(area == boss and subtitle == "Lair", "an instance comes before the place and kingdom it's in")
assert(area_choice.newly_entered({ instance = boss }, { instance = boss }, shown) == nil, "nothing while staying in it")
assert(area_choice.newly_entered({ instance = boss, place = town }, { instance = boss, place = farm }, shown) == nil,
    "nor for a place walked into inside an instance")

area, subtitle = area_choice.newly_entered({ place = town, kingdom = realm }, { kingdom = realm }, shown)
assert(area == town and subtitle == "Capital", "a place, with its own subtitle")
area, subtitle = area_choice.newly_entered({ place = farm, kingdom = realm }, { place = town, kingdom = realm }, shown)
assert(area == farm and subtitle == "Realm", "a place without one has its kingdom as subtitle")
area, subtitle = area_choice.newly_entered({ place = farm }, {}, shown)
assert(area == farm and subtitle == nil, "or none outside every kingdom")
assert(area_choice.newly_entered({ place = town, kingdom = other_realm }, { place = town, kingdom = realm }, shown) == nil,
    "crossing into another kingdom inside a place shows nothing")
area = area_choice.newly_entered({ place = town }, { instance = boss, place = town }, shown)
assert(area == nil, "leaving an instance into the place it was entered from shows nothing")

area, subtitle = area_choice.newly_entered({ kingdom = other_realm }, { kingdom = realm }, shown)
assert(area == other_realm and subtitle == nil, "a kingdom, outside any place")
assert(area_choice.newly_entered({ kingdom = other_realm }, { kingdom = realm }, hidden) == nil, "unless the player doesn't want its title")
assert(area_choice.newly_entered({ kingdom = realm }, { place = town, kingdom = realm }, shown) == nil,
    "leaving a place on its own shows nothing")
assert(area_choice.newly_entered({}, { place = town, kingdom = realm }, shown) == nil, "nor does leaving every area")

local name, title_subtitle, sprite = area_choice.title_of({ instance = boss, place = town, kingdom = realm })
assert(name == "Boss" and title_subtitle == "Lair" and sprite == nil, "the title of an instance")
name, title_subtitle, sprite = area_choice.title_of({ place = town, kingdom = realm })
assert(name == "Town" and title_subtitle == "Capital" and sprite == "SHIELD", "of a place")
name, title_subtitle = area_choice.title_of({ place = farm, kingdom = realm })
assert(name == "Farm" and title_subtitle == "Realm", "of a place without a subtitle of its own")
name, title_subtitle, sprite = area_choice.title_of({ kingdom = realm })
assert(name == "Realm" and title_subtitle == nil and sprite == "REALM_SHIELD", "of a kingdom")
assert(area_choice.title_of({}) == nil, "and none outside every area")
