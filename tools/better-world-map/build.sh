#!/usr/bin/env bash
# Copies your patched Better World Map (see README.md here) into the game's dev_plugins
# folder, as dev_plugins/BetterWorldMap.
#
#   tools/better-world-map/build.sh [path to BetterWorldMapPlugin]
#
# The path defaults to ../BetterWorldMapPlugin, next to this repo. dev_plugins_dir comes
# from build.local.sh, the same as for build.sh. Its git folder and docs are left out.
set -euo pipefail

cd "$(dirname "$0")/../.."

dev_plugins_dir=""
if [[ -f build.local.sh ]]; then
    source build.local.sh
fi
if [[ -z "$dev_plugins_dir" ]]; then
    echo "Set dev_plugins_dir in build.local.sh first (see build.sh)" >&2
    exit 1
fi
if [[ ! -d "$dev_plugins_dir" ]]; then
    echo "dev_plugins folder not found: $dev_plugins_dir" >&2
    exit 1
fi

source_dir="${1:-../BetterWorldMapPlugin}"
if [[ ! -f "$source_dir/plugin.json" ]]; then
    echo "No plugin.json in $source_dir" >&2
    exit 1
fi

out_dir="$dev_plugins_dir/BetterWorldMap"
rm -rf "$out_dir"
mkdir -p "$out_dir"
cp "$source_dir"/*.lua "$source_dir/plugin.json" "$out_dir/"
cp -r "$source_dir/resources" "$out_dir/"
echo "Copied $source_dir to $out_dir"
