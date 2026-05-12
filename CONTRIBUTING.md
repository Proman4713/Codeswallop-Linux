# Contributing to Utile OS
[![Build Utile OS 26.04 ISO](https://github.com/Proman4713/Utile-OS/actions/workflows/build-iso.yml/badge.svg)](https://github.com/Proman4713/Utile-OS/actions/workflows/build-iso.yml)

###### [Debian packages](https://github.com/Proman4713/Utile-OS-debian), [APT repository](https://github.com/Proman4713/Utile-OS-apt)

### Table Of Contents
- [Naming Scheme](#naming-scheme)
- [Codenames](#codenames)
- [Release Cycle](#release-cycle)

## Naming Scheme
The first thing to understand about this project is when to say 'Utile', 'Utile OS', 'Utile 26' and 'Utile OS 26':
- **Utile**:
	- In file and directory names (e.g. `/usr/share/pixmaps/utile-logo.svg`, `/boot/grub/themes/utile/`, `/etc/dconf/db/local.d/zz99_utile_defaults`)
	- In Debian package names (e.g. `utile-desktop`, `utile-gnome-defaults`, `utile-wallpapers`)
	- In shorthand IDs (e.g. `ID=utile` in `/etc/os-release`)
	- In marketing or logos
	- In any Utile app names (e.g. `Utile App Store`)
	- In internal metadata (e.g. `Utile Artistic` in `/usr/share/gnome-background-properties/abstract-wallpapers.xml`)
	- In casual discussion
- **Utile OS**:
	- In user-facing version-agnostic text across the system (e.g. `Install Utile OS`, `Utile OS` in GRUB, `Utile OS` instead of `Ubuntu Desktop` in Settings)
	- In general OS name declarations (e.g. `NAME="Utile OS"` in `/etc/os-release`)
	- In formal references (e.g. `Utile OS comes with ABSOLUTELY NO WARRANTY` in `/etc/legal`)
- **Utile 26**:
	- This should be avoided in most cases. Preferably kept only for casual discussion.
- **Utile OS 26**:
	- In user-facing version-specific text (e.g. `Utile OS 26 has experienced an internal error.` and other error messages, `Utile OS 26` in Settings > System > About)
	- In OS-differentiating locations (e.g. `PRETTY_NAME="Utile OS 26"` in `/etc/os-release`, which is used by neofetch/fastfetch, `Utile OS 26` in the post-install walkthrough dialogue). In other words, places where screenshots are taken.

Apps or services where the name is automatically picked from `/etc/os-release` - or similar files - are out of scope.

## Codenames
Utile follows a clear but fun naming scheme. It is composed of an adjective and a technical word starting with the same letter, starting with the letter A for Utile OS's first release (26) and going forward from there. The codename follows the exact same naming scheme as Ubuntu's (adjective only in files and code, full name in `/etc/os-release` and other user-facing text).
|	Adjective	|	Tech Word	|	Version	|	Upstream	|
|	:------:	|	:-------:	|	:-----:	|	:-----:		|
|	Abstract	|	Assembly	|	26		|	26.04.1		|
|	Bloated		|	Binaries	|	27		|	26.04.3		|
|	Clean		|	Code		|	28		|	28.04.1		|
|	Dazzling	|	Distribution|	29		|	28.04.3		|
|	Egregious	|	Error		|	30		|	30.04.1		|
|	Fractured	|	Filesystem	|	31		|	30.04.3		|
|	Gorgeous	|	Graphics	|	32		|	32.04.1		|
|	Helpful		|	Heuristic	|	33		|	32.04.3		|
|	Interwoven	|	Internet	|	34		|	34.04.1		|
|	Jittery		|	Joystick	|	35		|	34.04.3		|
|	Kinetic		|	Kernel		|	36		|	36.04.1		|

This, of course, naturally brings the flow of discussion over to the release cycle.

## Release Cycle
Utile OS is based on Ubuntu, which is a stable and reliable distribution, providing one LTS upgrade every two years which is supported for 5 years after that without Ubuntu Pro. Ubuntu interim releases aren't as stable as LTS releases, despite their offering of new features, and thus aren't supported by Utile OS. But I still want to offer more frequent upgrades than the standard Ubuntu LTS cycle, which are only given updates every 2 years. Therefore, Utile OS releases are going to be scheduled for August each year. This should already make sense given the previous table of codenames.

Let's take the [release cycle of Ubuntu 24.04](https://documentation.ubuntu.com/release-notes/24.04/schedule/) - the last LTS - for example. Ubuntu **24.04** LTS was released on **April 25th** 2024, similar to this year's **26.04** (released on **April 23rd**). This is *before* LTS upgrade prompts are sent to LTS users, since the standard LTS version isn't stable enough. This title goes to the **LTS .1** release, which, for **24.04.1**, was released on **August 29th** 2024. Ubuntu **22.04.1** was also released in **August**, and Ubuntu **26.04.1** LTS is scheduled for **August** as well.

This makes the August release cycle for Utile OS very robust, as it immediately jumps to the stable version of the next Ubuntu LTS, and also allows me to work on the upgrade process from April till August.

But this would only make sense if the August .1 plan worked *every* year, which isn't true, since Ubuntu LTS versions are only released every two years, and interim releases are only supported for 9 months, which wouldn't make them adequate for a 12-month upgrade cycle.

Therefore, for odd-year Augusts, when no new Ubuntu LTS versions are released, Utile is going to rely on Ubuntu LTS .3 releases, which are released the August after the previous .1 release, and mostly serve as bug fixes only, but can be used as an opportunity for Utile OS to ship new features, GNOME extensions, etcetera.

Given all of the above, I find very little need to clutter the Utile OS version numbers with multiple point segments, so **Ubuntu 26.04.1** will just translate to **Utile OS 26**, **Ubuntu 26.04.3** will translate to **Utile OS 27**, and so on.

I am unsure of whether I will be able to work on .2 and .4 LTS releases as well, but if I can, they will simply be .1 releases for their Utile OS counterparts rather than feature upgrades. So, assuming that I'll have the time and energy to do that:
- **Ubuntu 26.04.1** will become **Utile OS 26**
- **Ubuntu 26.04.2** will become **Utile OS 26.1**
- **Ubuntu 26.04.3** will become **Utile OS 27**
- **Ubuntu 26.04.4** will become **Utile OS 27.1**

This puts the Utile OS .1 releases at an also very consistent **February** release period, and the major Utile OS upgrades at the already discussed **August** release period. However, for now, only August releases are expected.