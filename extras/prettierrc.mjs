// Prettier settings for everything under ~.
// Plugins are the globally installed ones (npm i -g, prefix ~/.npm-global), looked up
// by package name on every run, so updating a plugin never breaks this config.
import { createRequire } from "node:module";
import { homedir } from "node:os";
import { join } from "node:path";

const fromGlobal = createRequire(join(homedir(), ".npm-global", "lib", "node_modules", "_"));

export default {
    plugins: [fromGlobal.resolve("prettier-plugin-java"), fromGlobal.resolve("@prettier/plugin-xml")],
    tabWidth: 4,
    experimentalOperatorPosition: "start",
    experimentalTernaries: true,
    printWidth: 120,
};
