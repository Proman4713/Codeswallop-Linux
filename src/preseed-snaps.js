const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { pipeline } = require("stream/promises");
const { Readable } = require("stream");

const SNAPS = [
	'snapd',
	'desktop-security-center',
	'firmware-updater',
	'gnome-46-2404',
	'bare',
	'gtk-common-themes',
	'mesa-2404',
	'prompting-client',
	'snap-store',
	'snapd-desktop-integration'
];
const ARCHITECTURE = 'amd64';
const CHANNEL = 'stable';

const BASE_SEED_DIR = path.join(__dirname, '..', 'tooling', 'config', 'includes.chroot', 'var', 'lib', 'snapd', 'seed');
const SNAPS_DIR = path.join(BASE_SEED_DIR, 'snaps');
const ASSERTIONS_DIR = path.join(BASE_SEED_DIR, 'assertions');

fs.mkdirSync(SNAPS_DIR, { recursive: true });
fs.mkdirSync(ASSERTIONS_DIR, { recursive: true });

async function fetchSnapInfo(snapName) {
	const url = `https://api.snapcraft.io/v2/snaps/info/${snapName}`;
	const response = await fetch(url, {
		headers: {
			'Snap-Device-Series': '16',
			'Content-Type': 'application/json',
		}
	});
	if (!response.ok) {
		const message = `Failed fetching info for ${snapName}: ${response.status} ${response.statusText}`;
		console.error(message);
		// fs.writeFileSync(path.join(__dirname, `${snapName}-error.log`), message + '\n' + (await response.text()));
		process.exit(1);
	}
	const data = await response.json();
	// console.log(data);

	const target = data['channel-map'].find(item =>
		item.channel.name === CHANNEL && item.channel.architecture === ARCHITECTURE
	);
	if (!target) throw new Error(`Could not find stable ${ARCHITECTURE} track for ${snapName}`);

	return {
		downloadUrl: target.download.url,
		revision: target.revision,
		snapId: data['snap-id'],
	};
}

async function downloadSnap(url, outputPath) {
    const snapRes = await fetch(url);

    if (!snapRes.ok) {
		console.error(`Failed to download snap: ${snapRes.status} ${snapRes.statusText}`);
		process.exit(1);
	}

    await pipeline(
    	Readable.fromWeb(snapRes.body),
    	fs.createWriteStream(outputPath)
    );
}

async function fetchAssertion(snapId, revision, outputPath) {
	const assertionRes = await fetch(
		`https://api.snapcraft.io/api/v1/snaps/assertions/snap-declaration/16/${snapId}?max-format=3`, {
			headers: {
				Accept: 'application/x.ubuntu.assertion'
			},
		}
	);
    if (!assertionRes.ok) {
		console.error(`Failed to fetch assertion: ${assertionRes.status} ${assertionRes.statusText}`);
		process.exit(1);
	}

    const assertion = await assertionRes.text();
    fs.writeFileSync(outputPath, assertion);
	console.log(`Saved ${outputPath}`);
}

async function main() {
	const seedManifest = {
		snaps: []
	};

	for (const snapName of SNAPS) {
		console.log(`\nProcessing: ${snapName}...`);
		try {
			const info = await fetchSnapInfo(snapName);
			console.log(info)

			const snapFile = `${snapName}_${info.revision}`;

			const snapPath = path.join(SNAPS_DIR, `${snapFile}.snap`);
			const assertPath = path.join(ASSERTIONS_DIR, `${snapFile}.assert`);

			console.log(`Downloading snap...`);
			await downloadSnap(info.downloadUrl, snapPath);

			console.log(`Downloading snap assertion...`);
			await fetchAssertion(info.snapId, info.revision, assertPath);

			seedManifest.snaps.push({
				name: snapName,
				channel: CHANNEL,
				file: `${snapFile}.snap`,
			});

			console.log(`Finished ${snapName}`);
		} catch (error) {
			console.error(`Error handling ${snapName}:`, error.message);
			process.exit(1);
		}
	}

	// Write final seed.yaml
	const yamlStr = yaml.dump(seedManifest);
	fs.writeFileSync(path.join(BASE_SEED_DIR, 'seed.yaml'), yamlStr);
	console.log('\nGenerated /var/lib/snapd/seed/seed.yaml');
}

main();