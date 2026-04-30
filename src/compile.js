// import fs, path for filesystem operations
const fs = require("node:fs");
const path = require("node:path");

// import Colours from javascript-console-styling, my own library for console styles: https://www.npmjs.com/package/javascript-console-styling
const Colours = require("javascript-console-styling/Colours");

// import project version from package.json
const { version } = require("../package.json");

// import spawn to spawn child sudo process for chmod command
const { spawn } = require('node:child_process');

// check if script is running in bash or zsh to prevent Windows users trying to contribute from experiencing errors with sudo
const isZsh = process.env.SHELL.includes("zsh");
const isBash = process.env.SHELL.includes("bash");

if (!isZsh && !isBash) {
	console.log(Colours.brightRed("This script must be run in bash or zsh! Use WSL if you're on Windows."));
	process.exit(1);
}

const CODESWALLOP_LINUX_VERSION = version.endsWith(".0") ? version.slice(0, -2) : version;

console.log(Colours.yellow(`Compiling bash patches for Codeswallop Linux ${CODESWALLOP_LINUX_VERSION} into production script...\n`));

// initiate 'compiled' script with shebang and greeting
let compiledScript = `#!/bin/bash
echo "${Colours.brightGreen("Setting up Codeswallop Linux...")}"`;

// read all .sh files in /patches directory
const files = fs.readdirSync(path.join(__dirname, "..", "patches"));

files.forEach(file => {
	const content = fs.readFileSync(
		path.join(__dirname, "..", "patches", file),
		{ encoding: "utf-8" },
	);

	if (!file.endsWith(".sh") || !content) {
		console.log(Colours.yellow(`Skipping ${file}...`));
		return;
	};

	compiledScript += ("\n" + `\n#^ PATCH FILE ${file}\n` + `\necho "APPLYING PATCH: ${file.replace(".sh", "")}"\n\n` + content);
});

// add closing message
compiledScript += `

echo "${Colours.brightGreen("Codeswallop Linux has finished setting up! Please reboot your system before using it.")}"`;

fs.writeFileSync(
	path.join(__dirname, "..", "dist", `codeswallop-linux-${CODESWALLOP_LINUX_VERSION}.sh`),
	compiledScript
)

console.log(Colours.green(`\nSuccessfully compiled script into ${path.join(__dirname, "..", "dist", `codeswallop-linux-${CODESWALLOP_LINUX_VERSION}.sh`)}!`));

// spawn child sudo process to run chmod
const child = spawn("sudo", ["chmod", "+x", path.join(__dirname, "..", "dist", `codeswallop-linux-${CODESWALLOP_LINUX_VERSION}.sh`)], {
	stdio: "inherit"
});
child.on('close', (code) => {
	console.log((code === 0 ? Colours.green : Colours.yellow)(`chmod exited with code ${code}`));
	process.exit(0);
});