const fs = require('fs');
const path = require('path');

// Get required version from common
const { common } = require("./common");
const SCRIPT_VERSION = new common(process.env.BUILD_TYPE === "release", process.env.GITHUB_REF_NAME).init().SCRIPT_VERSION;

const overlayPath = path.join(__dirname, "..", "tooling", "iso_overlay");
fs.mkdirSync(path.join(overlayPath, ".disk"), { recursive: true });

fs.writeFileSync(
	path.join(overlayPath, ".disk", "info"),
	`Utile OS 26 "Abstract Assembly" - Release amd64 (${SCRIPT_VERSION})`
);

fs.writeFileSync(
	path.join(overlayPath, ".disk", "release_notes_url"),
	`https://github.com/Proman4713/Utile-OS/releases/tag/${SCRIPT_VERSION}`
);

console.log(`\nutile-os-${SCRIPT_VERSION}`)