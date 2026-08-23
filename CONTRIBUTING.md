# Contributing to Utile OS
[![Build Utile OS 26 AMD64](https://github.com/Proman4713/Utile-OS/actions/workflows/build-amd64.yml/badge.svg)](https://github.com/Proman4713/Utile-OS/actions/workflows/build-amd64.yml)

###### [Debian packages](https://github.com/Proman4713/Utile-OS-debian), [APT repository](https://github.com/Proman4713/Utile-OS-apt)

### Table Of Contents
- [Naming Scheme](#naming-scheme)
- [Codenames](#codenames)
- [Release Cycle](#release-cycle)
- [Contributing](#contributing)
- [Building](#building)
- [Guide for New Contributors](#guide-for-new-contributors)

## Naming Scheme
The first thing to understand about this project is when to say 'Utile', 'Utile OS', 'Utile 26' and 'Utile OS 26':
- **Utile**:
	- in file and directory names (e.g. `/usr/share/pixmaps/utile-logo.svg`, `/boot/grub/themes/utile/`, `/etc/dconf/db/local.d/zz99_utile_defaults`)
	- in Debian package names (e.g. `utile-desktop`, `utile-gnome-defaults`, `utile-wallpapers`)
	- in shorthand IDs (e.g. `ID=utile` in `/etc/os-release`)
	- in marketing or logos
	- in any Utile app names (e.g. `Utile App Store`)
	- in internal metadata (e.g. `Utile Artistic` in `/usr/share/gnome-background-properties/abstract-wallpapers.xml`)
	- in casual discussion
- **Utile OS**:
	- in user-facing version-agnostic text across the system (e.g. `Install Utile OS`, `Utile OS` in GRUB, `Utile OS` instead of `Ubuntu Desktop` in Settings)
	- in general OS name declarations (e.g. `NAME="Utile OS"` in `/etc/os-release`)
	- in formal references (e.g. `Utile OS comes with ABSOLUTELY NO WARRANTY` in `/etc/legal`)
- **Utile 26**:
	- in public announcements, blog posts, PR mentions, etc.
	- This should be avoided in most other cases; preferably kept only for casual discussion.
- **Utile OS 26**:
	- in user-facing version-specific text (e.g. `Utile OS 26 has experienced an internal error.` and other error messages, `Utile OS 26` in Settings > System > About)
	- in OS-differentiating locations (e.g. `PRETTY_NAME="Utile OS 26"` in `/etc/os-release`, which is used by neofetch/fastfetch, `Utile OS 26` in the post-install walkthrough dialogue). In other words, places where screenshots are taken.

Apps or services that automatically pick the OS name from `/etc/os-release` or similar files are out of scope.

## Codenames
Utile follows a clear but fun naming scheme. It combines an adjective and a technical word starting with the same letter, starting with A for Utile OS's first release (26) and continuing from there. Utile OS codenames follow the same naming scheme as Ubuntu's (adjective-only in files and code; full name in `/etc/os-release` and other user-facing text).
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

This naturally brings the discussion to the release cycle.

## Release Cycle
Utile OS is based on Ubuntu, a stable, reliable distribution that provides one LTS upgrade every two years that's supported for 5 years after that without Ubuntu Pro. Ubuntu interim releases aren't as stable as LTS releases, despite their offering of new features, and thus aren't supported by Utile OS. But I still want to offer more frequent upgrades than the standard Ubuntu LTS cycle, which only gives updates every 2 years. Therefore, Utile OS releases will be scheduled for August each year. This should already make sense given the previous table of codenames.

Let's take the [release cycle of Ubuntu 24.04](https://documentation.ubuntu.com/release-notes/24.04/schedule/) - the last LTS - for example. Ubuntu **24.04** LTS was released on **April 25th** 2024, similar to this year's **26.04** (released on **April 23rd**). This is *before* LTS upgrade prompts are sent to LTS users, since the standard LTS version isn't stable enough. This title goes to the **LTS .1** release, which, for **24.04.1**, was released on **August 29th** 2024. Ubuntu **22.04.1** was also released in **August**, and Ubuntu **26.04.1** LTS is scheduled for **August** as well.

This makes the August release cycle for Utile OS very robust, as it immediately jumps to the stable version of the next Ubuntu LTS and lets me work on the upgrade process from April to August.

But this only makes sense if the August .1 plan worked *every* year, which it doesn't, since Ubuntu LTS versions are released only every two years, and interim releases are supported for only 9 months, which isn't adequate for a 12-month upgrade cycle.

Therefore, for odd-year Augusts, when no new Ubuntu LTS versions are released, Utile is going to rely on Ubuntu LTS .3 releases, which are released the August after the previous .1 release, and mostly serve as bug fixes only, but can be used as an opportunity for Utile OS to ship new features, GNOME extensions, etcetera.

Given all of the above, I see little need to clutter Utile OS version numbers with multiple point segments, so **Ubuntu 26.04.1** will just translate to **Utile OS 26**, **Ubuntu 26.04.3** will translate to **Utile OS 27**, and so on.

I am unsure of whether I will be able to work on .2 and .4 LTS releases as well, but if I can, they will be .1 releases for their Utile OS counterparts rather than feature upgrades. So, assuming that I'll have the time and energy to do that:
- **Ubuntu 26.04.1** will become **Utile OS 26**
- **Ubuntu 26.04.2** will become **Utile OS 26.1**
- **Ubuntu 26.04.3** will become **Utile OS 27**
- **Ubuntu 26.04.4** will become **Utile OS 27.1**

This also puts the Utile OS .1 releases on a very consistent **February** schedule, and the major Utile OS upgrades on the already discussed **August** schedule. For now, however, only August releases are expected.

## Contributing
Contributing is as simple as submitting an Issue or Pull Request with a good description and valuable information. I currently see no need to restrict how people can make contributions.

Any references to 'OOBE' in the comments in this code are short for 'Out-of-the-Box Experience', an abbreviation borrowed from Windows's less-than-ideal experience to emphasise this project's legitimate focus around the user's first-time, zero-knowledge experience.

## Building
### Prerequisite Explanation
This OS's composition could be incredibly confusing at first glance. However, as it turns out, there's rarely any documentation at all for many of the things covered in this project. As far as I'm concerned, no other Linux distribution properly documents its building process for the public. If you're new to this realm and want to contribute, check out the [Guide for New Contributors](#guide-for-new-contributors) down below.

Now, and for the foreseeable future, there will only be a few things that make Utile OS what it is instead of a clone of Ubuntu:
* APT Sources
* upstream Debian package pinning
* new Debian packages
* different build tools and preinstalled packages
* ISO packing
* ISO-level or system-level configuration files and/or deletions
* Systemd configuration
* ISO-level initramfs
* Snap pre-seeding

Although that may seem like a lot, many of them are closely related.

APT Sources, package pinning, and new Debian packages cover *everything* related to user settings, extensions, defaults, apps, and system metadata; I won't explain these uses here because they are fundamentally irrelevant to the general concepts outlined above.

Now, for the ISO structure, we have some explaining to do&hellip;

#### ISO packing
It may surprise you, if you've never worked on similar things before, that a standard Ubuntu or Linux Mint ISO is only a bare-bones bootable device for your device's firmware. It contains no actual root filesystem&hellip; *That* resides inside the `casper/` directory as a compressed file with the `.squashfs` extension, usually written [SquashFS](https://en.wikipedia.org/wiki/SquashFS) (short for *Squashed Filesystem*), which contains the actual [root filesystem](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03.html) that gives you the live USB environment. That SquashFS is [created](https://manpages.ubuntu.com/manpages/resolute/man1/mksquashfs.1.html) for [`casper`](https://manpages.ubuntu.com/manpages/resolute/man7/casper.7.html) (the name of the folder) to extract into RAM and mount it as the root filesystem.

*Casper* is an [InitramFS](https://wiki.archlinux.org/title/Arch_boot_process#initramfs) hook (more on how that happens later) made by Canonical for Ubuntu ISOs. It is therefore used both by Utile OS and Linux Mint, which we can call 'sibling distributions' in relation to Ubuntu Desktop. In Ubuntu ISOs, the `casper/` directory contains *multiple* .squashfs files with different names, because Ubuntu uses a more complicated *layered filesystem* layout than both Utile OS and Linux Mint's single `filesystem.squashfs` files.

The `casper/` directory contains a few other files:
* `filesystem.manifest`
* `filesystem.size`
* `filesystem.manifest-remove` (soon to exist in Utile OS)
* `vmlinuz`
* `initrd`
* `install-sources.yaml`

`filesystem.manifest` contains a sorted `dpkg-query` of all the packages installed on the squashfs; there is no clear documentation on what `casper` uses it for, but Ubuntu ISOs also list the installed *snap* packages at the end of their `.manifest` files. It could rather be used by the installer, where Linux Mint uses Ubiquity (Ubuntu's old installer), and Utile OS [currently] uses Ubuntu Desktop Bootstrap (Ubuntu's more modern, Flutter-based installer).

*filesystem.size* contains the size (in bytes) of the target system root (before it is compressed into SquashFS). Or, at least, that's what it appears to be from Ubuntu, Mint, and Utile's ISOs.
##### Note: Previously, Utile OS was 'built' by downloading an Ubuntu 26.04 ISO and modifying it; during that time, a new `.squashfs` was generated, and the build script calculated its size in bytes for the `.size` file. The system installed successfully, and that `.size` value didn't cause any issues. I speculate that *this file is used for the Ubuntu installer to give a 'not enough disk space' warning when the user's disk doesn't have enough space*

`filesystem.manifest-remove` has never been tested for Utile OS because, as I mentioned, I haven't added it to our ISOs yet.

`vmlinuz` and `initrd` are the most complicated. In essence, they are just a compressed image of the Linux kernel and an InitramFS, respectively. What's complicated, though, is how they *end up* in the ISO's `casper/` directory when *no functional Linux system exists there.* More on that later.

The `install-sources.yaml` file is yet another [undocumented bit of Canonical magic](https://discourse.ubuntu.com/t/automated-server-installer-config-file-reference/16613/46); this is its value for Utile OS 26 (Ubuntu 26.04.1):
```yaml
kernel:
  default: linux-generic-hwe-24.04
sources:
- default: true
  description:
    en: The full Utile OS experience.
  id: ubuntu-desktop-minimal
  locale_support: langpack
  name:
    en: Standard
  path: filesystem.squashfs
  preinstalled_langs:
  - ''
  size: $FILESYSTEM_SIZE
  type: fsimage
  variant: desktop
  variations:
    standard:
      path: filesystem.squashfs
      size: $(stat -c %s "$ISO_DIR/casper/filesystem.squashfs")
version: 2

```
`$FILESYSTEM_SIZE` is referring to the value in `filesystem.size`. And the `stat` command returns the size of the `.squashfs` file in bytes. As the link above mentions, without this file the Ubuntu installer would believe that it's installing an Ubuntu Server instance (*why*, you may ask, when it is clearly a desktop GUI installer? The answer is: Ubuntu Desktop Bootstrap uses Subiquity, the same installer backend Ubuntu Server uses, and only surfaces it through a GUI). So I added this file to make the installer show 'Standard Selection' (which *does* seem a bit pointless, considering that Utile OS only offers one selection of apps. But we currently have no control over our installation process, and that should change) instead.

#### ISO- or system-level configurations
Regarding those configurations, such as the GRUB config for the ISO or Debian repository keyrings for the system, everything is pretty straightforward: I hardcode them, and that's the only way to do it.

Let's look at the `/etc/apt/preferences.d/official-package-repositories.pref` file in Utile OS; it wasn't always called that, but I changed the name to match Linux Mint's just because the previous `utile.pref` seemed a bit off:
```yaml
Package: *
Pin: release o="Utile OS",c=upstream
Pin-Priority: 700
```
Although this isn't important to our current topic, this file pins all Utile APT packages from the `upstream` component with a priority of `700` because these packages will conflict with Ubuntu/Debian upstreams; therefore, we need a way to tell APT to choose ours.\
Anyway, this file is simply hardcoded into Utile OS installations and doesn't require much work. If we ever need to change it, then that would be up to our future upgrade utility.

#### Systemd
Changes in enabled/disabled systemd units compared to Ubuntu Desktop. Currently, the only systemd unit whose status we try to enforce is `apparmor`, where we run `systemctl enable apparmor` as a potential solution to Brave's apparmor issues when preinstalled on Utile OS (rather than post-installed).

#### ISO InitramFS
That one, the `initrd` file in the `casper/` directory&hellip; It's there so that the GRUB bootloader on the ISO uses it and the kernel (`vmlinuz`) to start *a* Linux system (very bare-bones), and the aforementioned Casper hook in that InitramFS looks for the `filesystem.squashfs` (or whatever you configure it to look for) and loads it.

That InitramFS isn't as bare-bones as you might think, however, since it contains Systemd, Plymouth, Snap seeding hooks (more on it soon), Casper, and other things that make it behave like an Ubuntu system until the actual SquashFS loads and the system inside *it* starts booting.\
Have you ever noticed your Ubuntu Live USB flickering for a moment, just to show an identical boot splash? That's likely why. In fact, in Utile OS's early days, when we modified an existing Ubuntu ISO, I wasn't aware of the complexities around this `initrd`, so when I changed the Ubuntu logos in the boot splash screen *inside* the SquashFS, the change didn't reflect in the ISO's `initrd`, so the Ubuntu logo would show briefly before the screen flickered and Utile's logo appeared.

#### Snap Seeding
*Somehow*, I consider this the most complicated topic we've talked about. The Snap ecosystem is *incredibly* undocumented, and that alone honestly makes me want to remove it from Utile OS more than any other reason Ubuntu-based distros often choose to remove it. However, Utile still doesn't have superb alternatives to Ubuntu's system snaps, so we're keeping them.

I wonder how Snap is meant to work across distributions (like Flatpak) if it is so hard to *use* (I'm not even talking about having the option to maintain 'Snap repositories' or anything similar) for such distributions. I've found *trickles* of information in the Ubuntu Core documentation, though.

Anyway, I've documented most of what I found. And here are the basics:

Snaps are preinstalled on Ubuntu through an operation called 'pre-seeding'. The snap daemon runs early in the boot process the first time you run your PC, then verifies and installs all the provided snaps.

This 'pre-seed' information is mostly in `/var/lib/snapd/seed`, where we have two directories: `snaps/` and `assertions/`&hellip;

The `snaps/` directory contains `.snap` files that you can get (alongside a `.assert` file for the other directory) from the `snap download` command on your system; they contain the actual snap package.

The `assertions/` directory contains the `.assert` file for each snap, plus three others: `model`, `account-key`, and `account`. Since this seeding happens for Utile OS in an isolated CI/CD environment, I didn't want to depend on `snapd`, so I used the Snapcraft API (`https://api.snapcraft.io/v2/`), which is ***severely*** undocumented. The closest thing to proper documentation I've found is https://api.snapcraft.io/docs/.

Those three assertions follow the `generic` account on Snapcraft, which is what is used for non-Ubuntu Core (i.e., Desktop) in official ISOs.
* The `model` assertion is obtained through the API's `/assertions/model/SERIES/BRAND_ID/MODEL_KEY`, or, in this case, `/assertions/model/16/generic/generic-classic`. `16` is currently a static value without much meaning. Note that an `Accept: 'application/x.ubuntu.assertion'` header is required.
* The `account-key` assertion is obtained through the `/assertions/account-key/SIGNING_KEY` endpoint; the signing key is whichever line follows the `sign-key-sha3-384:` value in the model assertion.
* The `account` assertion is obtained through the `/assertions/account/NAME` endpoint, or `/account/generic` in this case. The name is the owner brand specified in the model assertion.

All three assertions are used to verify Canonical's (or a brand's) identity in relation to a pre-seed for Ubuntu Core (with that signed model assertion [explicitly specifying which snaps and revisions are allowed](https://documentation.ubuntu.com/core/tutorials/build-your-first-image/create-a-model/#snaps)). However, Desktop uses this generic model.

Since Canonical doesn't mention this anywhere in the Ubuntu Core documentation (pretty much the only resource explaining what models are), I was briefly led to believe that I had to set up a Snapcraft brand and sign a model to make the snap daemon successfully seed. I instead messed things up further by convincing the daemon's seeding process that this was an Ubuntu Core system; it tried to do things that aren't available on Desktop (namely accessing a `modeenv` file). The real solution was helping the daemon by doing some of the pre-seeding in advance (more on that later).

For the snaps' `.assert` files, each one actually has *three* assertions in one file that `snapd` uses to verify the whole package. They are, in order:
* an `account-key` assertion similar to the one that we have in the dedicated `account-key` file, but this one is used to verify the developer account for its snap package (who, for all of Utile OS's built-in snaps, is Canonical, so this assertion will constantly be a duplicate of the assertion in the standalone file). The signing key in the API request for this assertion will be whichever line follows the `sign-key-sha3-384:` value in the `snap-declaration` assertion.
* a `snap-declaration` assertion (obtained through `/assertions/snap-declaration/SERIES/SNAP_ID`; I'll specify details on ID retrieval soon) provides metadata for the package (the ID, timestamp, owner brand, and signing key)
* a `snap-revision` assertion (obtained through `/assertions/snap-revision/HASH`; this is the sha3-384 hash of the `.snap` file) verifies that this is a valid revision of the snap as published by its brand

So we get the `snap-declaration` assertion first, but we only add it to the file after `account-key` to match `snap download`'s assertions (although this isn't needed).

So these are all the assertions; now more explanation&hellip;

A Snap's ID (alongside its download URL, revision number, 'type', and channel) is obtained through `/snaps/info/NAME`, such as `/snaps/info/firmware-updater`. The `Snap-Device-Series: 16` and `Content-Type: 'application/json'` headers are required. The 'type' of a snap doesn't seem to have clear documentation, but I've seen values like `app`, `kernel`, `snapd`, `base`, and others. This endpoint returns a JSON object with all currently published revisions of this snap and their details, so Utile OS's [`preseed-snaps.js`](./src/preseed-snaps.js) script can filter the required revision by its architecture and channel.

A snap seed can be validated locally (without test-booting every attempt) with this command:
```bash
snap debug validate-seed /path/to/seed/
```

The seeding directory can be anywhere, as long as it resembles `/var/lib/snapd/seed` and follows the structure explained a moment ago.

Now, I mentioned 'helping the daemon' earlier by doing some of the pre-seeding ourselves. How? The answer lies in yet *another* undocumented utility: [`snap-preseed`](https://github.com/canonical/snapd/blob/master/cmd/snapd/tool/snap-preseed/main.go). This program lives in `/usr/lib/snapd/`, and it runs part of the process the snap daemon runs when you first boot your PC but often gets stuck on or finishes too late because the task is quite time-consuming. This program needs only one argument: a path to the target system's root to [`chroot`](https://wiki.archlinux.org/title/Chroot) (a utility [that changes the apparent root filesystem for a process](https://wiki.debian.org/chroot)) into; in this case, it's the live environment before it is compressed into a SquashFS.

You can run this program after you've created a basic system root filesystem (e.g., using `debootstrap`, which doesn't need to be covered in this documentation), installed `snapd` inside it, and prepared a good `/var/lib/snapd/seed` directory. This program requires standard `chroot` virtual filesystem mounts such as `/dev`, `/dev/pts`, `/proc`, `/sys`, and `/run`, but it also requires `/sys/kernel/security` to avoid errors.

### The Build Process
Everything we've talked about so far culminates in this: how do we build an Ubuntu-based distribution such as Utile OS? Why is doing some things better than others? This section covers that, but know that Utile OS's build process (which we're about to describe) isn't expected to be perfect or foolproof, since it's still very much a work in progress&hellip;

TODO

## Guide for New Contributors
TODO