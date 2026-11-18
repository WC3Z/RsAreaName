-- Instances by the value of BOSS_INSTANCE_CURRENT_BOSS while the player is in
-- them. For bosses it's their BSLAY_ID (Boss Slayer, or Reaper task, id), and
-- these names are the game's BSLAY_NAMEs, split into name and subtitle, or
-- with where the boss is (from the wiki) as the subtitle. Some bosses only set
-- it once the fight starts, like Solak and Raksha. Heists use it too, with ids
-- found by visiting them. Some bosses never set it, like Silverquill, or
-- aren't in an instance, like the Chaos Elemental; those are known by the
-- name on their health bar instead, once the fight starts. The bar can show
-- the name, the name and subtitle ("Silverquill the Dreadhog"), or one of
-- the bar_names.
---@type table<integer, WorldInstance>
return {
    [1] = { name = "Araxxi", subtitle = "Araxyte Hive" },
    [2] = { name = "The Barrows Brothers", subtitle = "Morytania" },
    [3] = { name = "Rise of the Six", subtitle = "The Barrows" },
    [4] = { name = "Chaos Elemental", subtitle = "The Wilderness" },
    [5] = { name = "Commander Zilyana", subtitle = "God Wars Dungeon" },
    [6] = { name = "Corporeal Beast", subtitle = "The Wilderness" },
    [7] = { name = "Dagannoth Kings", subtitle = "Waterbirth Island",
        bar_names = { "Dagannoth Rex", "Dagannoth Prime", "Dagannoth Supreme" } },
    [8] = { name = "General Graardor", subtitle = "God Wars Dungeon" },
    [9] = { name = "Giant Mole", subtitle = "Falador" },
    [10] = { name = "Har-Aken", subtitle = "Fight Kiln" },
    [11] = { name = "Kalphite King", subtitle = "Exiled Kalphite Hive" },
    [12] = { name = "Kalphite Queen", subtitle = "Kalphite Lair" },
    [13] = { name = "King Black Dragon", subtitle = "The Wilderness" },
    [14] = { name = "Kree'arra", subtitle = "God Wars Dungeon" },
    [15] = { name = "K'ril Tsutsaroth", subtitle = "God Wars Dungeon" },
    [16] = { name = "Legiones", subtitle = "Ascension Dungeon" },
    [17] = { name = "Nex", subtitle = "Ancient Prison" },
    [18] = { name = "Queen Black Dragon", subtitle = "Grotworm Lair" },
    [19] = { name = "TzTok-Jad", subtitle = "TzHaar Fight Cave" },
    [20] = { name = "Vorago", subtitle = "Borehole" },
    [21] = { name = "Beastmaster Durzag", subtitle = "Liberation of Mazcab" },
    [22] = { name = "Yakamaru", subtitle = "Liberation of Mazcab" },
    [23] = { name = "The Twin Furies", subtitle = "Heart of Gielinor" },
    [24] = { name = "Vindicta & Gorvek", subtitle = "Heart of Gielinor", bar_names = { "Vindicta", "Gorvek" } },
    [25] = { name = "Gregorovic", subtitle = "Heart of Gielinor" },
    [26] = { name = "Helwyr", subtitle = "Heart of Gielinor" },
    [27] = { name = "Telos", subtitle = "Heart of Gielinor" },
    [28] = { name = "Nex: Angel of Death", subtitle = "Ancient Prison" },
    [29] = { name = "The Magister", subtitle = "Sophanem Slayer Dungeon" },
    [30] = { name = "Solak", subtitle = "Guardian of the Grove" },
    [31] = { name = "The Sanctum Guardian", subtitle = "Temple of Aminishi" },
    [32] = { name = "Masuta the Ascended", subtitle = "Temple of Aminishi" },
    [33] = { name = "Seiryu the Azure Serpent", subtitle = "Temple of Aminishi" },
    [34] = { name = "Astellarn", subtitle = "Dragonkin Laboratory" },
    [35] = { name = "Verak Lith", subtitle = "Dragonkin Laboratory" },
    [36] = { name = "Black Stone Dragon", subtitle = "Dragonkin Laboratory" },
    [37] = { name = "Crassian Leviathan", subtitle = "The Shadow Reef" },
    [38] = { name = "Taraket the Necromancer", subtitle = "The Shadow Reef" },
    [39] = { name = "The Ambassador", subtitle = "The Shadow Reef" },
    [40] = { name = "Raksha", subtitle = "The Shadow Colossus" },
    [41] = { name = "Rex Matriarchs", subtitle = "Anachronia" },
    [42] = { name = "Kerapac", subtitle = "The Bound" },
    [43] = { name = "Arch-Glacor", subtitle = "Glacor Front" },
    [44] = { name = "Croesus", subtitle = "Croesus Front" },
    -- Named after the area, since 17 waves come before Zuk himself.
    [45] = { name = "TzekHaar Front", subtitle = "TzKal-Zuk", bar_names = { "TzKal-Zuk" } },
    [46] = { name = "Zamorak", subtitle = "Lord of Chaos" },
    [47] = { name = "Hermod", subtitle = "The Spirit of War" },
    [48] = { name = "Rasial", subtitle = "The First Necromancer" },
    [49] = { name = "Zemouregal & Vorkath", subtitle = "Fort Forinthry", bar_names = { "Zemouregal", "Vorkath" } },
    [50] = { name = "Vermyx", subtitle = "Brood Mother" },
    [51] = { name = "Kezalam", subtitle = "The Wanderer" },
    [52] = { name = "Nakatra", subtitle = "Devourer Eternal" },
    [53] = { name = "The Gate of Elidinis", subtitle = "Sanctum of Rebirth" },
    [54] = { name = "Amascut", subtitle = "The Devourer" },
    [55] = { name = "Flesh-hatcher Mhekarnahz", subtitle = "Daemonheim" },
    [56] = { name = "Ivar", subtitle = "King of Bones" },
    [57] = { name = "Silverquill", subtitle = "The Dreadhog" },
    [58] = { name = "The Ghrazi Blood Knights", subtitle = "Crimson Throne" },
    -- Heists
    [500] = { name = "Asuran Arsenal", subtitle = "Anachronia", heist = true },
    [501] = { name = "Vault of Hereditas", subtitle = "Kharid-et Dig Site", heist = true }
}
