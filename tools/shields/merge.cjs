// Merges lodestone shield sprites exported from the game files with their
// alpha masks into transparent PNGs in resources/shields/, which the plugin
// shows instead of the game's sprites (whose masks the API can't apply).
//
//   node merge.cjs [folder with the exports]   (default: ../../debug/shields)
//
// Each shield is two files named after its sprite without THAS_SHIELD_, in
// lower case: varrock.png (THAS_SHIELD_VARROCK) and varrock_alpha.png
// (THAS_SHIELD_VARROCK_ALPHA). The mask is greyscale: white is solid, black is
// see-through. Output: resources/shields/THAS_SHIELD_VARROCK.png.
const fs = require("fs");
const path = require("path");
const sharp = require("sharp");

const inputDir = path.resolve(process.argv[2] || path.join(__dirname, "../../debug/shields"));
const outputDir = path.join(__dirname, "../../resources/shields");

async function merge(name) {
    const picture = await sharp(path.join(inputDir, `${name}.png`)).removeAlpha().raw().toBuffer({ resolveWithObject: true });
    const mask = sharp(path.join(inputDir, `${name}_alpha.png`)).extractChannel(0);
    const maskSize = await mask.metadata();
    if (maskSize.width !== picture.info.width || maskSize.height !== picture.info.height) {
        throw new Error(`${name}: picture and mask are different sizes`);
    }
    const alpha = await mask.raw().toBuffer();
    const output = path.join(outputDir, `THAS_SHIELD_${name.toUpperCase()}.png`);
    await sharp(picture.data, { raw: picture.info })
        .joinChannel(alpha, { raw: { width: picture.info.width, height: picture.info.height, channels: 1 } })
        .png()
        .toFile(output);
    console.log(`${name} -> ${path.relative(process.cwd(), output)}`);
}

async function main() {
    fs.mkdirSync(outputDir, { recursive: true });
    const names = fs.readdirSync(inputDir)
        .filter((file) => file.endsWith("_alpha.png"))
        .map((file) => file.slice(0, -"_alpha.png".length))
        .filter((name) => fs.existsSync(path.join(inputDir, `${name}.png`)));
    if (names.length === 0) {
        console.error(`No <name>.png + <name>_alpha.png pairs in ${inputDir}`);
        process.exit(1);
    }
    for (const name of names) {
        await merge(name);
    }
}

main().catch((error) => {
    console.error(error.message);
    process.exit(1);
});
