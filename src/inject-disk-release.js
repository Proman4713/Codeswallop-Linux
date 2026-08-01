const fs = require('fs');
const path = require('path');

// Get required version from common
const { common } = require("./common");
const SCRIPT_VERSION = new common(process.env.BUILD_TYPE === "release", process.env.GITHUB_REF_NAME).init().SCRIPT_VERSION;

const binaryIncludePath = path.join(__dirname, "..", "tooling");
fs.mkdirSync(path.join(binaryIncludePath, ".disk"), { recursive: true });

fs.writeFileSync(
	path.join(binaryIncludePath, ".disk", "info"),
	/*
		! LTS HERE ONLY! Some behaviour suggests that the Ubuntu Flutter installer is hardcoded for Ubuntu; in that case,
		! I would like it to think this is an LTS. There isn't enough documentation to even be sure that this text is used.
	*/
	`Utile OS 26 LTS "Abstract Assembly" - Release amd64 (${SCRIPT_VERSION})`
);

fs.writeFileSync(
	path.join(binaryIncludePath, ".disk", "release_notes_url"),
	`https://github.com/Proman4713/Utile-OS/releases/tag/${SCRIPT_VERSION}`
);

console.log(`\nutile-os-${SCRIPT_VERSION}`)