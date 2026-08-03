const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const crypto = require('crypto');
const { pipeline } = require('stream/promises');
const { Readable } = require('stream');
const { execSync } = require('child_process');

const SNAPS = [
	'core24',
	'core22',
	'snapd',
	'desktop-security-center',
	'firmware-updater',
	'gnome-46-2404',
	'bare',
	'gtk-common-themes',
	'mesa-2404',
	'prompting-client',
	'snap-store',
	'snapd-desktop-integration',
	'ubuntu-desktop-bootstrap?{ "classic": true }'
];
const ARCHITECTURE = 'amd64';
const CHANNEL = 'stable';
const UBUNTU_VERSION = '26.04';
const UTILE_VERSION = '26';
const API = 'https://api.snapcraft.io/v2';
const SNAP_SERIES = 16;
const SNAP_ACCOUNT = 'wrtkSz6GPFgTcq4LGAN5OdKkGtyWEt3n';
const SIGN_KEY_REGEX = /^sign-key-sha3-384:\s*(\S+)/m;

// To be /var/lib/snapd/seed
const BASE_SEED_DIR = path.join(__dirname, '..', 'tooling', 'seed');
const SNAPS_DIR = path.join(BASE_SEED_DIR, 'snaps');
const ASSERTIONS_DIR = path.join(BASE_SEED_DIR, 'assertions');
const DOWNLOAD_RETRIES = 3;
const RETRY_DELAY_MS = 2000;

/**
 * @type {{ [x:string]: Response }}
 * @description We've been getting lots of 429s
 */
let requestCache = {};

fs.mkdirSync(SNAPS_DIR, { recursive: true });
fs.mkdirSync(ASSERTIONS_DIR, { recursive: true });

/**
 * 
 * @param {string} url 
 * @param {RequestInit} options 
 * @param {number} retries 
 * @returns {Response}
 */
async function fetchWithRetry(url, options = {}, retries = DOWNLOAD_RETRIES) {
	let lastError;
	for (let attempt = 1; attempt <= retries; attempt++) {
		try {
			const REQ_HASH = url + JSON.stringify(options);
			//dbg console.log(`Request hash: ${REQ_HASH}`)
			if (Object.keys(requestCache).includes(REQ_HASH)) {
				const response = requestCache[REQ_HASH];
				//dbg console.log(`Request is cached, returning ${response.url} ${response.ok}`)

				// Clone it so it can be consumed again
				requestCache[REQ_HASH] = response.clone();
				// If it's been cached then it was successful
				return response;
			}

			const response = await fetch(url, options);
			if (!response.ok) {
				lastError = new Error(`Request failed: ${response.status} ${response.statusText}`);
				console.warn(`Attempt ${attempt}/${retries} failed: ${lastError.message}`);
			} else {
				//dbg console.log(`Request was successful, caching request hash ${REQ_HASH} at ${response.url} ${response.ok}`)

				requestCache[REQ_HASH] = response.clone();
				return response;
			}
		} catch (error) {
			lastError = error;
			console.warn(`Attempt ${attempt}/${retries} failed: ${error.message}`);
		}

		if (attempt < retries) {
			await new Promise(resolve => setTimeout(resolve, RETRY_DELAY_MS));
		}
	}
	throw lastError || new Error('Failed to fetch after retries');
}

async function fetchSnapInfo(snapName) {
	const url = `${API}/snaps/info/${snapName}`;
	const response = await fetchWithRetry(url, {
		headers: {
			'Snap-Device-Series': SNAP_SERIES,
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
	//dbg console.log(data);

	let target = null;
	const searchPattern = new RegExp(`^./${CHANNEL}`);
	for (const potentialTarget of data['channel-map']) {
		if (potentialTarget.channel.architecture !== ARCHITECTURE) continue;

		if (potentialTarget.channel.name.match(searchPattern)) {
			target = {...potentialTarget};
			break;
		};

		if (potentialTarget.channel.name === CHANNEL) {
			target = {...potentialTarget};
			// Continue in case we find the `/${CHANNEL}` condition later (e.g., 1/stable for firmware-updater)
			continue;
		}
	}

	if (!target) throw new Error(`Could not find ${CHANNEL} ${ARCHITECTURE} track for ${snapName}`);

	return {
		downloadUrl: target.download.url,
		revision: target.revision,
		type: target.type,
		snapId: data['snap-id'],
		targetChannel: target
	};
}

async function downloadSnap(url, outputPath) {
	await fetchWithRetry(url).then(async (snapRes) => {
		await pipeline(
			Readable.fromWeb(snapRes.body),
			fs.createWriteStream(outputPath)
		);
	}).catch(error => {
		console.error(`Failed to download snap: ${error.message}`);
		process.exit(1);
	});
}

async function fetchAssertion(assertionType, path, outputPath) {
	const assertionRes = await fetchWithRetry(
		`${API}/assertions/${assertionType}/${path}`, {
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
    if (outputPath) {
		fs.writeFileSync(outputPath, assertion);
		console.log(`Saved ${outputPath}`);
	}
	return assertion;
}

async function main() {
	//* Model and account assertions
	try {
		const modelAssertionFile = path.join(ASSERTIONS_DIR, 'model');
		let modelAssertion = await fetchAssertion('model', `${SNAP_SERIES}/generic/generic-classic`);
		fs.writeFileSync(modelAssertionFile, modelAssertion);
		console.log(`Saved ${modelAssertionFile}`);

		// Get account signing key
		const accountKeyFile = path.join(ASSERTIONS_DIR, `account-key`);
		const modelAccountKeyAssertion = await fetchAssertion('account-key', modelAssertion.match(SIGN_KEY_REGEX)[1]);
		fs.writeFileSync(accountKeyFile, modelAccountKeyAssertion);
		console.log(`Saved ${accountKeyFile}`);

		const accountAssertionFile = path.join(ASSERTIONS_DIR, `account`);
		const accountAssertion = await fetchAssertion('account', `generic`);
		fs.writeFileSync(accountAssertionFile, accountAssertion);
		console.log(`Saved ${accountAssertionFile}`);
	} catch (error) {
		console.error(`Error handling special assertions:`, error.message);
		process.exit(1);
	}

	const seedManifest = {
		snaps: []
	};

	for (const snapQuery of SNAPS) {
		const [snapName, snapOptions] = snapQuery.split('?');

		console.log(`\nProcessing: ${snapName}...`);
		try {
			const info = await fetchSnapInfo(snapName);
			//dbg console.log(info)

			const snapFile = `${snapName}_${info.revision}`;

			const snapPath = path.join(SNAPS_DIR, `${snapFile}.snap`);
			const assertPath = path.join(ASSERTIONS_DIR, `${snapFile}.assert`);

			console.log(`Downloading snap...`);
			await downloadSnap(info.downloadUrl, snapPath);

			console.log(`Downloading snap assertion...`);

			const snapDeclarationAssertion = await fetchAssertion('snap-declaration', `${SNAP_SERIES}/${info.snapId}`);

			// Get Canonical account key assertion (since we're using official snaps) among any others if we use third-party snaps
			const accountKeyAssertion = await fetchAssertion('account-key', snapDeclarationAssertion.match(SIGN_KEY_REGEX)[1]);

			// Get the assertion
			const snapFileBuffer = fs.readFileSync(snapPath);
			const snapRevisionHash = crypto.createHash('sha3-384').update(snapFileBuffer).digest('base64url');
			//dbg console.log(snapRevisionHash);
			const snapRevisionAssertion = await fetchAssertion('snap-revision', snapRevisionHash);

			fs.writeFileSync(assertPath, accountKeyAssertion + '\n' + snapDeclarationAssertion + '\n' + snapRevisionAssertion);

			let extraOptions = JSON.parse(snapOptions || '{}');
			//dbg console.log(extraOptions)

			const snapChannel = (info.targetChannel.channel.name.includes(`/${CHANNEL}`))
									? `${info.targetChannel.channel.name}/ubuntu-${UBUNTU_VERSION}`
									: `${info.targetChannel.channel.track}/${info.targetChannel.channel.name}`;
			seedManifest.snaps.push({
				name: snapName,
				channel: snapChannel,
				file: `${snapFile}.snap`,
				...extraOptions
			});

			//dbg console.log(seedManifest.snaps[length - 1]);

			console.log(`Finished ${snapName}`);
		} catch (error) {
			console.error(`Error handling ${snapName}:`, error.message);
			process.exit(1);
		}
	}

	const yamlStr = yaml.dump(seedManifest,).replaceAll('- ', '-\n    ');
	fs.writeFileSync(path.join(BASE_SEED_DIR, 'seed.yaml'), yamlStr);
	console.log('\nGenerated /var/lib/snapd/seed/seed.yaml');
}

main();