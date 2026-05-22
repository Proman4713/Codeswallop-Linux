const fs = require('fs');
const path = require('path');

const { version } = require("../package.json");

const UTILE_OS_VERSION = version.replace(/(\.0+)+$/, '');

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
	Example Nightly:	utile-os-26-nightly-26w18a
	Example Beta:		utile-os-26-v1.0.0-beta1
	Example Release:	utile-os-26-v1.0.0
*/
const SCRIPT_VERSION = process.env.BUILD_TYPE === "release" && process.env.GITHUB_REF_NAME ?
	`${UTILE_OS_VERSION}-${process.env.GITHUB_REF_NAME}` :
	`${UTILE_OS_VERSION}-nightly-${now.getFullYear().toString().slice(-2)}w${weekNumber.toString().padStart(2, "0")}${dayLetter}`;

const binaryIncludePath = path.join(__dirname, "..", "tooling", "config", "includes.binary");
fs.mkdirSync(path.join(binaryIncludePath, ".disk"), { recursive: true });

fs.writeFileSync(
	path.join(binaryIncludePath, ".disk", "info"),
	`Utile OS 26 "Abstract Assembly" - Release amd64 (${SCRIPT_VERSION})`
);

fs.writeFileSync(
	path.join(binaryIncludePath, ".disk", "release_notes_url"),
	`https://github.com/Proman4713/Utile-OS/releases/tag/${SCRIPT_VERSION}`
);

console.log(`\nutile-os-${SCRIPT_VERSION}`)