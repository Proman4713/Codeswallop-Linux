![Utile Logo](./resources/Utile%20Transparent%20Lockup.svg)
# A Minimum-Friction Linux Desktop
Ubuntu derivative with Quality-of-Life and Aesthetic Improvements

[![Build Utile OS 26 ISO](https://github.com/Proman4713/Utile-OS/actions/workflows/build-iso.yml/badge.svg)](https://github.com/Proman4713/Utile-OS/actions/workflows/build-iso.yml)

###### [Debian packages](https://github.com/Proman4713/Utile-OS-debian), [APT repository](https://github.com/Proman4713/Utile-OS-apt)

### Table Of Contents
- [Quick Start](#quick-start)
- **[Disclaimers & Agreements (Read Before Using)](#disclaimers--agreements)**
- [Support me](#support-me)
- [Structure](#structure)
- [Plans](#plans)
- [Why?](#why)
- [Rights & Licensing](#rights--licensing)
- [Contributing](#contributing)

## Quick Start
- Status: Pre-Release Snapshots
- Target Audience: Ubuntu, Windows 11, macOS users
- Minimum Requirements:
	1. A USB drive of at least **8GBs**.
	3. Internal Storage: **25GB** minimum.
	4. RAM: **6GB** recommended.
	5. VRAM: **256MB** minimum, **1GB or more** recommended. **3D Acceleration** strongly recommended.
	6. Secure Boot: Optional, although **Disabled** gives you a better-looking boot screen.

## Disclaimers & Agreements
- This project is **not** designed for personal use by anyone other than myself. I claim no liability for anything this project may do to your system as of now. If you use this project, you do so at your own risk.
- I do not make the ISOs easily accessible for download on the repository's homepage for multiple reasons:
	1. The ISOs are largely untested and may not work at all.
	2. The ISOs are neither feature-complete nor bug-free.
	3. The ISOs have not yet been completely rid of Ubuntu branding. So it may be the case that they are not completely out of the scope of Canonical's trademarks, which is something that needs to change before this project is ready for distribution.
	4. The above means that I'm not claiming any rights over Canonical/Ubuntu brand elements that are still user-facing and yet to be removed. Nor am I suggesting that this is a project made by Canonical Ubuntu. It is simply a matter of time before the situation changes.
- The ISOs have not been tested with offline Ubuntu installations.
- The bash scripts available in my [releases](https://github.com/Proman4713/Utile-OS/releases) are not intended for use on an existing system. They assume a specific Ubuntu version depending on their filename and also assume that they are the first thing being run on your system. The vast majority of any customisations you may have applied will be overridden.
- This project has already modified enough that Ubuntu upgrades may not go smoothly. This is something that even I am not willing to risk on my own system. This shall change before the final release with a custom upgrade solution.
- This project uninstalls some packages from the Extended Selection, so be wary of that if you run it on an Ubuntu extended installation.
- Considering that this project is mainly targeted at ISOs, the bash scripts are not [idempotent](https://en.wikipedia.org/wiki/Idempotence), and they also modify **both** system and user defaults, so creating a new user after running this project does not uninstall the changes applied by the script.
- This project is ***not*** endorsed or supported by Canonical, Ubuntu, or any other Linux distribution. It is a personal project somewhere between base Ubuntu and a custom Ubuntu derivative.
- I am the only maintainer of this project. If you have any suggestions, please open an issue on the [Issues](https://github.com/Proman4713/Utile-OS/issues) page, but don't expect much from me. This is largely a hobby project dedicated to myself and learning some things about Linux.
- By using this project, you also agree to the **[Microsoft Core Fonts EULA](https://corefonts.sourceforge.net/eula.htm).** Because it is automatically accepted during the installation of LibreOffice onto your system or onto the ISO.

## Support me
If you somehow found this project useful, or used my wallpapers for your desktop, then please consider [buying me a coffee](https://buymeacoffee.com/codeswallop) :)

## Structure
This project applies a set of 'patches' in the form of .bash files to modify certain aspects of the Ubuntu desktop. The patches are designed to build up a new system from the ground up rather than blindly importing configs or dconf dumps onto the system. This reduces the need to edit parts of the script based on updates in Ubuntu, GNOME, GNOME shell extensions, or anything else.

The patches are 'compiled' through the NodeJS [`compile.js`](./src/compile.js) script, which generates one big .sh file that can be applied to both ISOs and Ubuntu installations. The .sh files are then uploaded to GitHub releases and made available for download. This allows me to modularise the patches for ease of development, but also provide one shell script for ease of use and deployment.

The reason the patches are given the .bash extension, even though the product script is given the .sh extension, is to allow the [ShellCheck VSCode extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) to provide errors and warnings without repetitive shebangs in each patch.

Local development & build instructions are not yet available. Although if you really wanted to, you could check out the [ISO Build workflow](https://github.com/Proman4713/Utile-OS/blob/main/.github/workflows/build-iso.yml), which uses the NodeJS script, to replicate a similar process locally. If this works out, feel free to contribute your solution to the repository.

## Plans
Before starting this project, I detailed a specific plan in [an older readme](./README.old.md#plan); however, I have since realised that those plans were not realistically laid out due to various intricacies around how Ubuntu and apt/debian packages work. So this section is being repurposed for future plans. I write these plans when I think of them, and they are subject to change.

<details>
	<summary>Plans</summary>
	<ol>
		<li><strike>Make my own APT repository and Debian packages.</strike></li>
		<li><strike>Override upstream's <code>base-files</code> package to provide logos and release metadata</strike></li>
		<li><strike>Change bashrc to use a lighter colour for the <code>user@computer</code> text</strike></li>
		<li><strike>Either contribute my distribution's ASCII symbol to <code>fastfetch</code> or include it in a debian package and set the <code>--logo</code> argument in a bashrc alias of <code>fastfetch</code>/<code>neofetch</code></strike></li>
		<li>Implement my own Plymouth theme.</li>
		<li>Figure out a way to use/implement an equivalent of the <code>Customised Workspaces</code>, <code>Customize Clock on Lock Screen</code>, and <code>Lock screen background</code> extensions without cluttering the UI</li>
		<li>Fully transition to use Debian packages (i.e. make more packages) to make modifications rather than manually executing commands.</li>
		<li>Similarly, make a <code>utile-gnome-shell-extensions</code> package to be able to install preferred extensions as system extensions and update them without needing the hacky <code>seed_extension</code> function in patch 000.</li>
		<li>Create a <code>utile-gnome-defaults</code> package for the gsettings/dconf changes</li>
		<li>Implement a custom upgrade solution to handle my own package repositories and hold Ubuntu upgrades until I finish syncing this project with upstream.</li>
		<li>Implement my own app store (packaged in Debian, not a Snap), which makes the issue of Snap vs. Debian less of a technical dilemma and more of a user-friendly choice. This app store must also improve on the UI/UX of usual Linux app stores, which, in my opinion, are developed by people who are too tech-centric to dedicate enough thought to the appeal of their UI. Additionally, I would like to allow developers to publish Debian-packaged apps to this store even if they don't come from the device's apt sources. This could potentially be done by verifying a developer's identity and their app's safety, then only adding their app's source repository if the user chooses to install the app.</li>
	</ol>
</details>
<details>
	<summary>Debatable</summary>
	<ol>
		<li>Should I add ClamAV? Potentially with a custom extension to go with it to provide a GUI in the top bar/quick settings?</li>
		<li>Should I allow a custom wallpaper for the lock screen through extensions (potentially custom, to unify GDM login and lock screen)?</li>
		<li>Should I create an extension to reduce the size of the headerbar in GNOME, especially with fractional scaling?</li>
		<li>Should I include a pre-configure 'Dash2Dock Animated' extension? Is that too much like macOS in a way that it shouldn't be?</li>
		<li>Similarly, what about the 'Compiz alike magic lamp effect' extension? This could be too much, but maybe another extension that provides a springier minimise animation than the default?</li>
		<li>Should I include auto-cpufreq/thermald by default for better battery life? Perhaps with an extension to provide a UI for that as well?</li>
		<li>The average user does not have NAS devices and doesn't use <a href="https://ubuntu.com/server/docs/how-to/networking/install-nfs/">NFS</a>, should I disable the NetworkManager-wait-online.service to speed up boot time? What are the tradeoffs?</li>
	</ol>
</details>

## Why?
Utile OS started as an idea for my YouTube channel, [Codeswallop](https://youtube.com/@lots_of_codeswallop), where I intend to publish a series of video essays based around Linux desktop system design and UX. For these videos, I'll need to research and address various pain points (tiny or large) in the Linux desktop - with Ubuntu particularly serving as a starting point - that slowly accumulate to cause a total result of inexplicable frustration for a user transitioning from another OS.

The YouTube videos are meant to talk from a technically unrestricted perspective where I can present pain points and what could be done about them without consistently looking into why one solution is - or isn't - realistic from a technical/backend perspective. This will give me more room to address the significant majority of pain points from a UX-only perspective to provide a framework that a technical organisation could use to pin goals and later think about technical possibilities or implementations to determine what is worth pursuing first.

If you want to read more from me about this, then I'm pleased to say that there exists an unfortunate rant in the [old readme file](./README.old.md#why).

This project serves as a container for everything that I dare to try to address these pain points.

'**Utile**' (pronounced 'you-tile') is an old English word that meant 'Useful' before Shakespeare decided to first write the now famous word. It was derived from Middle French and still exists in the French language to this day. I particularly picked this word to highlight the helpfulness that I want to provide with this project.

## Rights & Licensing
- This project is licensed under the well-known GPL v3, which covers all the code and shell scripts written here. The license is available inside [`LICENSE.md`](LICENSE.md).
- On the other hand, media files available at [`resources/`](resources/) are licensed using Creative Commons, which covers images, designs, audio, video, and everything else that may exist in that folder as long as it contains the same Creative Commons license. The license available at [`resources/LICENSE.md`](resources/LICENSE.md).
