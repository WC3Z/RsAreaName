-- The sounds a title can play (the choices on the Sound tab), and playing them.
local db = require("src/database/db")

local title_sounds = {}

-- Game sounds, from id.Sound, listed alphabetically as they show on the Sound
-- tab.
title_sounds.all = {
    -- The default (see db.get_sound).
    { id = "achievement", label = "Achievement", sound = id.Sound.CHEEVO_ACHIEVEMENT_COMPLETE_SOUND_V3 },
    { id = "amascut_meow", label = "Amascut meow", sound = id.Sound.DQB_AMAS_EMOTE_VO_DAMAGE_03 },
    { id = "amascut_snarl", label = "Amascut snarl", sound = id.Sound.DQB_AMAS_EMOTE_VO_SNARLS_01 },
    { id = "bond_fanfare", label = "Bond fanfare", sound = id.Sound.RS_BONDS_FANFARE_1 },
    { id = "carousel_ding", label = "Carousel ding", sound = id.Sound.MTXFEST17_CAROUSEL_DINGNOCHEER_01 },
    { id = "death_jingle", label = "Death jingle", sound = id.Sound.DEATH2_JINGLE },
    { id = "harp_run", label = "Harp run", sound = id.Sound.HW10_HARP_047_060 },
    { id = "harp_strum", label = "Harp strum", sound = id.Sound.HW10_HARP_STRUM_01 },
    { id = "lute_chord", label = "Lute chord", sound = id.Sound.SIGHERO_LUTE_CHORD_1 },
    { id = "lute_chord_2", label = "Lute chord 2", sound = id.Sound.SIGHERO_LUTE_CHORD_2 },
    { id = "lute_chord_3", label = "Lute chord 3", sound = id.Sound.SIGHERO_LUTE_CHORD_3 },
    { id = "lute_chord_4", label = "Lute chord 4", sound = id.Sound.SIGHERO_LUTE_CHORD_4 },
    { id = "memory_bell", label = "Memory bell", sound = id.Sound.QUEST_CHAROS_ENTER_MEMORY_BELL },
    { id = "research_finished", label = "Research done", sound = id.Sound.ARCH_RESEARCH_FINISHED },
    { id = "soft_sleigh_bells", label = "Soft sleigh bells", sound = id.Sound.SANTAYAK_SOFT_BELLS_01 },
    { id = "spooky_piano", label = "Spooky piano", sound = id.Sound.SPOOKY_PIANO_1 },
    { id = "thok_fanfare", label = "Thok fanfare", sound = id.Sound.DM_THOK_ESCAPE_FANFARE },
    { id = "valentines_progress", label = "Valentine's progress", sound = id.Sound.VALENTINES_2021_PROGRESS_COMPLETE },
    { id = "valentines_task", label = "Valentine's task done", sound = id.Sound.VALENTINES_2021_TASK_COMPLETE }
}

-- Sounds the game doesn't have, like a number past the last snarl, are left
-- out, so every choice plays something.
for index = #title_sounds.all, 1, -1 do
    if title_sounds.all[index].sound == nil then
        table.remove(title_sounds.all, index)
    end
end

-- Stops a sound. Stopping one that has already finished is an error in game
-- (the docs say it does nothing), so that's caught.
---@param sound audio.SoundInstance
function title_sounds.stop(sound)
    pcall(function () sound:Stop() end)
end

-- The sound with the given id in title_sounds.all, or nil if it isn't there
-- (like one removed from the list).
---@param sound_id string?
local function sound_with_id(sound_id)
    for _, sound in ipairs(title_sounds.all) do
        if sound.id == sound_id then
            return sound
        end
    end
    return nil
end

-- Plays a sound, even with sounds turned off, to hear it on the settings page:
-- the one with the given id (nothing if it isn't in the list any more), or
-- without one, the one picked in the settings.
---@param sound_id string? An id in title_sounds.all
---@return audio.SoundInstance? playing
function title_sounds.play(sound_id)
    local sound
    if sound_id then
        sound = sound_with_id(sound_id)
        if not sound then
            return nil
        end
    else
        -- The first one if the saved id isn't there (like one saved by an older version).
        sound = sound_with_id(db.get_sound()) or title_sounds.all[1]
    end
    if not sound or not sound.sound then
        return nil
    end
    return audio.Play(sound.sound)
end

return title_sounds
