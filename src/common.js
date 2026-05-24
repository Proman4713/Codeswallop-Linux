const {
	version
} = require("../package.json");

class common {
	IS_RELEASE=false;
	REL_TAG="";
	UTILE_OS_VERSION = version.replace(/(\.0+)+$/, '');

	now = new Date();
	// Jan 1st
	startOfYear = new Date(this.now.getFullYear(), 0, 1);
	// Number of days since Jan 1st
	numOfDays = Math.floor((this.now - this.startOfYear) / (24 * 60 * 60 * 1000));
	weekNumber = Math.floor((this.numOfDays + this.startOfYear.getDay()) / 7) + 1;
	letters = "abcdefg";
	dayLetter = this.letters[this.now.getDay()];

	/*
		Example Nightly:	utile-os-26-nightly-26w18a
		Example Beta:		utile-os-26-v1.0.0-beta1
		Example Release:	utile-os-26-v1.0.0
	*/
	SCRIPT_VERSION = this.IS_RELEASE && this.REL_TAG ?
		`${this.UTILE_OS_VERSION}-${this.REL_TAG}` :
		`${this.UTILE_OS_VERSION}-nightly-${this.now.getFullYear().toString().slice(-2)}w${this.weekNumber.toString().padStart(2, "0")}${this.dayLetter}`;

	constructor(isRelease=false, releaseTag="") {
		this.IS_RELEASE = isRelease;
		this.REL_TAG = releaseTag;
	}

	calcVer() {
		/*
			Example Nightly:	utile-os-26-nightly-26w18a
			Example Beta:		utile-os-26-v1.0.0-beta1
			Example Release:	utile-os-26-v1.0.0
		*/
		this.SCRIPT_VERSION = this.IS_RELEASE && this.REL_TAG ?
			`${this.UTILE_OS_VERSION}-${this.REL_TAG}` :
			`${this.UTILE_OS_VERSION}-nightly-${this.now.getFullYear().toString().slice(-2)}w${this.weekNumber.toString().padStart(2, "0")}${this.dayLetter}`;
	}

	init() {
		console.log(`WEEK DAY: ${this.now.getDay()} == ${this.now.toLocaleDateString("en-US", { weekday: "long" })}`);
		this.calcVer();
		console.log(`CALCULATED VERSION: ${this.SCRIPT_VERSION}`);
		return this;
	}
}

module.exports = {
	common
}