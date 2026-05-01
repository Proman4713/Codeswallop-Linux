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

	compiledScript += ("\n" + `\n#^ PATCH FILE ${file}\n` + `\necho -e "\\nAPPLYING PATCH: ${file.replace(".sh", "")}\\n"\n\n` + content);
});

// add closing message
compiledScript += `

echo "${Colours.brightGreen("Codeswallop Linux has finished setting up! Please reboot your system before using it.")}"`;

const now = new Date();
// Jan 1st
const startOfYear = new Date(now.getFullYear(), 0, 1);
// Number of days since Jan 1st
const numOfDays = Math.floor((now - startOfYear) / (24 * 60 * 60 * 1000));
const weekNumber = Math.floor((numOfDays + startOfYear.getDay()) / 7) + 1;
const letters = "abcdefg";
const dayLetter = letters[now.getDay()];

console.log(`WEEK DAY: ${now.getDay()} == ${now.toLocaleDateString("en-US", { weekday: "long" })}`);

/*
	Example Nightly:	codeswallop-linux-26.04-nightly-26w18a
	Example Beta:		codeswallop-linux-26.04-v1.0.0-beta1
	Example Release:	codeswallop-linux-26.04-v1.0.0
*/
const SCRIPT_VERSION = process.env.BUILD_TYPE === "release" && process.env.GITHUB_REF_NAME
						? `${CODESWALLOP_LINUX_VERSION}-${process.env.GITHUB_REF_NAME}`
						: `${CODESWALLOP_LINUX_VERSION}-nightly-${now.getFullYear().toString().slice(-2)}w${weekNumber.toString().padStart(2, "0")}${dayLetter}`;

fs.mkdirSync(path.join(__dirname, "..", "dist"), { recursive: true });

fs.writeFileSync(
	path.join(__dirname, "..", "dist", `codeswallop-linux-${SCRIPT_VERSION}.sh`),
	compiledScript
)

console.log(Colours.green(`\nSuccessfully compiled script into ${path.join(__dirname, "..", "dist", `codeswallop-linux-${SCRIPT_VERSION}.sh`)}!`));

// spawn child sudo process to run chmod
const child = spawn("sudo", ["chmod", "+x", path.join(__dirname, "..", "dist", `codeswallop-linux-${SCRIPT_VERSION}.sh`)], {
	stdio: "inherit"
});
child.on('close', (code) => {
	console.log((code === 0 ? Colours.green : Colours.yellow)(`chmod exited with code ${code}`));
	console.log(`codeswallop-linux-${SCRIPT_VERSION}.sh`);
	process.exit(0);
});