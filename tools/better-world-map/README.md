# Area Names on Better World Map

Better World Map by jadefx is a world map plugin. With the additions in this folder, your copy of it draws Area Names' borders on its map and lets you trace an area's outline by clicking on the map. It's a tool for mapping areas (see [Mapping areas](../../README.md#mapping-areas)), not something players need.

Better World Map's author lets anyone use and change its code. The additions here are made for version 0.18.3.

## What's here

- `area_names_overlay.lua`: a new file for Better World Map. It draws the areas ticked on Area Names' **Map borders** tab, each in its own colour with its name, and handles Ctrl+clicks on the map.
- `better_world_map.patch`: the changes to Better World Map's own files:
  - `plugin.json`: Area Names as an optional dependency, by the folder name of its dev build: `"optionalDependencies": { "AreaNames": "Area-Names" }`.
  - `main.lua`: creates the overlay, draws it with the map, redraws it when Area Names' settings change, and passes Ctrl+clicks on the map to it.
- `build.sh`: copies your patched Better World Map into the game's `dev_plugins` folder.

Area Names itself needs no changes: its `main.lua` already returns its areas, corners and border settings for plugins that depend on it.

## Setting it up

1. Get Better World Map's source into a folder next to this repo, named `BetterWorldMapPlugin`:

   ```
   your-plugins/
     AreaNames/
     BetterWorldMapPlugin/
   ```

   Another place works too; then give its path to `build.sh` in step 4.

2. Copy the overlay into it:

   ```sh
   cp tools/better-world-map/area_names_overlay.lua ../BetterWorldMapPlugin/
   ```

3. Apply the patch, from inside Better World Map's folder:

   ```sh
   cd ../BetterWorldMapPlugin
   git apply ../AreaNames/tools/better-world-map/better_world_map.patch
   ```

   Or without git: `patch -p1 < ../AreaNames/tools/better-world-map/better_world_map.patch`. If it doesn't apply, Better World Map has probably changed since 0.18.3; the patch is small enough to make the changes by hand.

4. Set `dev_plugins_dir` in `build.local.sh`, as for Area Names' own `build.sh` (see [Building](../../README.md#building)). Then build both plugins:

   ```sh
   ./build.sh
   tools/better-world-map/build.sh              # or: tools/better-world-map/build.sh path/to/BetterWorldMapPlugin
   ```

   This copies Better World Map to `dev_plugins/BetterWorldMap`, leaving out its git folder and docs.

5. In game, register Better World Map's map images, which it needs before its map shows: `poff BetterWorldMap`, then `prf`, then `pon BetterWorldMap`. Area Names has to be loaded too; plugins load their dependencies first.

When Better World Map is updated, the additions are gone: start again from step 2.

## Using it

1. On Area Names' **Map borders** tab, tick **Show area borders**, and tick the areas you want to see. None are ticked at first, as drawing them all is slow.
2. Open the map with **M**. The ticked areas are drawn on whichever map is open, including the underground ones, each with its name at its middle.
3. To trace an outline, **Ctrl+click** each corner in turn:
   - **Ctrl+Shift+click** removes the last corner.
   - **Ctrl+Alt+click** clears the corners.

   The corners are drawn in magenta. Each click prints the outline so far to the chat, ready to paste into Area Names' `world_areas.lua`:

   ```
   [Area Names] { name = "New place", points = { { 2987, 2878 }, { 3020, 3020 }, ... } },
   ```

   The clicks give real tiles, even where the map shows a region moved away from its real place (Havenhythe, Prifddinas, Anachronia).

4. Corners marked in game with **Mark corner** show on the map too, in white.

Without Area Names loaded, Better World Map works as it always does: nothing is drawn and Ctrl+click pans the map like a normal click.
