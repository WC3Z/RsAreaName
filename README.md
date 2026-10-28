# Area Names

A RuneScape 3 plugin that announces where you are, like the area titles in the Souls games: when you walk into a town, cross into another kingdom or arrive somewhere by teleport, its name fades in across the screen.

![The Varrock title, with its lodestone shield, over Varrock's square](images/varrock.png)

## Features

- **Towns, kingdoms and places.** Walking into a town shows the town, with its own subtitle or the kingdom it's in. Crossing into another kingdom shows the kingdom. Places away from the main world, like War's Retreat or Death's Office, and boss instances like Telos, have their own titles too.
- **Lodestone shields** above the names of areas that have one.
- **No titles during loading screens.** After a teleport, the title waits until the loading screen is over, then shows where you arrived.
- **No repeats when walking back in.** Stepping out of a town and straight back in doesn't show its title again for a while (see Settings). Arriving by teleport always shows it.

## Settings

On the plugin's page (its ribbon icon):

- **Font**, **Font size** and **Colour** of the title. Fonts only come in fixed sizes, so the size is greyed out for fonts that have just one.
- **Show shields**: the lodestone shield above the name.
- **Play a sound** and **Sound**: a sound as the title appears. Needs the game's sound effects turned on.
- **Repeat titles after (minutes)**: how long before an area's title shows again when you walk back in. 0 shows it every time.
- **Preview**: shows the title for where you are now, or an example when that's nowhere named.

## Contributing areas

New areas, better borders and fixes to the ones there are very welcome. All of them are in [`src/game/world_areas.lua`](src/game/world_areas.lua). Positions are **world tiles** (a map square is 64 of them), the `x` and `z` of the player's `coordGrid`.

There are three kinds:

- **Towns** are circles: a middle and a radius in tiles. The title shows when you're inside the circle, and you only count as having left at 1.2 times the radius, so walking along the edge doesn't show it again and again. Where circles overlap, the town whose middle is nearest wins.

  ```lua
  { name = "Varrock", subtitle = "Capital of Misthalin", sprite = "THAS_SHIELD_VARROCK", at = { 3213, 3428 }, radius = 55 },
  ```

- **Kingdoms** are one or more rectangles, each `{ min x, min z, max x, max z }`. The first kingdom in the list with a rectangle you're in wins, so put a smaller kingdom before a bigger one that overlaps it.

  ```lua
  { name = "Misthalin", bounds = { { 3045, 3136, 3269, 3519 }, { 3270, 3320, 3390, 3519 } } },
  ```

- **Places** are areas away from the main world, made of rectangles like kingdoms: worlds of their own (like War's Retreat) and the places instances are copied from (like the Telos fight). They come before towns and kingdoms.

  ```lua
  { name = "War's Retreat", bounds = { { 3200, 10112, 3327, 10175 } } },
  ```

`subtitle` and `sprite` are optional for all three. `sprite` is a name from the game's sprites (`id.Sprite`); the lodestone shields are the `THAS_SHIELD_...` ones.

### Finding coordinates

`src/game/area_debug.lua` prints where you are to the chat. Turn it on by adding it to `main.lua`:

```lua
local area_debug = require("src/game/area_debug")
area_debug.start()
```

and `area_debug.stop()` in `PluginShutdown`. It prints your tile whenever the world or an instance is built, and in an instance, the tile it was copied from, which is the one to use for a place. It also says which town and kingdom you've walked into, which is handy for checking borders. The [RuneScape Wiki](https://runescape.wiki) lists coordinates for many locations too.

## Building

```sh
./build.sh           # copies the plugin into Area-Names/
./build.sh release   # the same, for publishing
```

To also copy dev builds into your game's `dev_plugins` folder, create `build.local.sh` (it's gitignored) with:

```sh
dev_plugins_dir="$HOME/path/to/RuneScape-BETA/dev_plugins"
```

The plugin depends on the [prettyui](https://prettyui.j3.gg/) plugin (see `plugin.json`).

## Licence

Public domain ([The Unlicense](LICENSE)): do whatever you want with the code.
