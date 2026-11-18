// Runs the plugin's Lua outside the game: checks every file compiles, then runs each *_test.lua
// in tests/ with the plugin's src/ files available to require. The tests fake the parts of the
// game's API they use.
//
//   cd tests && npm install && npm test
import { LuaFactory } from "wasmoon";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const testsDir = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(testsDir, "..");

function luaFiles(dir) {
    return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
        const file = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            return luaFiles(file);
        }
        return entry.name.endsWith(".lua") ? [file] : [];
    });
}

const sourceFiles = [...luaFiles(path.join(root, "src")), path.join(root, "main.lua")];
const testFiles = fs.readdirSync(testsDir).filter((name) => name.endsWith("_test.lua")).sort();
let failed = 0;

const checker = await new LuaFactory().createEngine();
for (const file of sourceFiles) {
    const name = path.relative(root, file);
    try {
        await checker.doString(`assert(load(${JSON.stringify(fs.readFileSync(file, "utf8"))}, ${JSON.stringify(name)}))`);
    } catch (error) {
        console.log(`FAIL compile ${name}: ${error.message}`);
        failed++;
    }
}

for (const testFile of testFiles) {
    // A fresh Lua for each test, so modules and fakes from one don't leak into the next.
    const factory = new LuaFactory();
    for (const file of sourceFiles) {
        await factory.mountFile(path.relative(root, file), fs.readFileSync(file, "utf8"));
    }
    const lua = await factory.createEngine();
    try {
        await lua.doString(fs.readFileSync(path.join(testsDir, testFile), "utf8"));
        console.log(`ok   ${testFile}`);
    } catch (error) {
        console.log(`FAIL ${testFile}: ${error.message.split("\n")[0]}`);
        failed++;
    } finally {
        lua.global.close();
    }
}

console.log(failed === 0 ? "All passed" : `${failed} failed`);
process.exit(failed === 0 ? 0 : 1);
