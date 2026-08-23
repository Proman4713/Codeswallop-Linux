![Utile Logo](./resources/Utile%20Transparent%20Lockup.svg)
# A Minimum-Friction Linux Desktop
Ubuntu derivative with Quality-of-Life and Aesthetic Improvements

[![Build Utile OS 26 AMD64](https://github.com/Proman4713/Utile-OS/actions/workflows/build-amd64.yml/badge.svg)](https://github.com/Proman4713/Utile-OS/actions/workflows/build-amd64.yml)

###### [Debian packages](https://github.com/Proman4713/Utile-OS-debian), [APT repository](https://github.com/Proman4713/Utile-OS-apt), [Website Frontend](https://github.com/Proman4713/Utile-OS-web)

### Table Of Contents
- [Quick Start](#quick-start)
- **[Disclaimers & Agreements (Read Before Using)](#disclaimers--agreements)**
- [Support me](#support-me)
- [Structure](#structure)
- [Plans](#plans)
- [Why?](#why)
- [Rights & Licensing](#rights--licensing)
- [Contributing](CONTRIBUTING.md)

## Quick Start
- Status: Pre-Release Snapshots
- Target Audience: Ubuntu, Windows 11, macOS users
- Minimum Requirements:
	1. A USB drive of at least **8GB**.
	3. Internal Storage: **25GB** minimum for comfortable use.
	4. RAM: **6GB** recommended for suitable everyday usage.
	5. VRAM: **256MB** minimum, **1GB or more** recommended. **3D Acceleration** strongly recommended in VMs.
	6. Secure Boot: Optional, although **Disabled** gives you a better-looking boot screen.

## Disclaimers & Agreements
- This project is **not** designed for personal use by anyone other than myself. <b>Use it at your own risk;</b> I claim no liability for anything it may do to your system at the moment. Potential issues include, but are not limited to, system instability, broken packages, or failure to boot. Please test only on spare systems or virtual machines.
- I do not make the ISOs easily accessible for download on the repository's homepage for multiple reasons:
	1. The OS is largely untested; it's neither feature-complete nor bug-free.
	2. The OS has not yet been completely rid of Ubuntu branding. So it may not be entirely outside the scope of Canonical's trademarks, which need to be removed before this project is ready for distribution.
	3. I'm not claiming any rights over Canonical/Ubuntu brand elements that are still user-facing and not yet removed, and I'm not suggesting that this is a project made by Canonical/Ubuntu. It is simply a matter of time before the situation changes.
- The ISOs have not been tested with offline installations.
- The bash scripts available in my [releases](https://github.com/Proman4713/Utile-OS/releases) are not intended for use on a long-running system. They assume a specific Ubuntu version based on their filename and that they are the *first thing* run on your system, so most customisations you may have applied **will be overridden**.
- This project has already modified enough that Ubuntu upgrades may not go smoothly. Even I am not willing to risk that on my own system; this shall change before the final release with a custom upgrade solution.
- This project uninstalls crucial packages from the Extended Selection, so do not run the bash script on an Ubuntu extended installation.
- Since this project mainly targets ISOs, the bash scripts are not [idempotent](https://en.wikipedia.org/wiki/Idempotence) and modify **both** system and user defaults, so creating a new user after running this project does not undo any changes.
- This project is ***not*** endorsed or supported by Canonical, Ubuntu, or any other Linux distribution. It is a personal project somewhere between base Ubuntu and a custom Ubuntu derivative.
- I am the only maintainer of this project. If you have any suggestions, please open an issue on the [Issues](https://github.com/Proman4713/Utile-OS/issues) page, but don't expect much from me. This is largely a hobby project for me to learn more about Linux, while exploring UX improvements for the desktop experience. Technical information for contributors is in [`CONTRIBUTING.md`](CONTRIBUTING.md).
- By using this project, you agree to the **[Microsoft Core Fonts EULA](https://corefonts.sourceforge.net/eula.htm)** because it is automatically accepted during the installation of LibreOffice on your system or onto the ISO.

## Support me
If you somehow found this project useful, or used my wallpapers for your desktop, then please consider [buying me a coffee](https://buymeacoffee.com/codeswallop) :)

## Structure
This project applies a set of 'patches' in the form of .bash files to modify certain aspects of the Ubuntu desktop and improve the everyday experience. The patches are designed to build a new system from the ground up rather than dumbly importing configs or dconf dumps, reducing the need to edit them when Ubuntu, GNOME, GNOME Shell extensions, or anything else is updated.

In the build process, the patches are 'compiled' through the NodeJS [`compile.js`](./src/compile.js) script, which generates one big .sh file that works for both ISOs and Ubuntu installations. The .sh files are then uploaded to GitHub releases and made available for download. This keeps the patches modular for easier development, while still providing one shell script for easy use and deployment.

The patches use the .bash extension, while the product script is given the .sh extension, so the [ShellCheck VSCode extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck) can provide errors and warnings without repetitive shebangs in each patch.

Local development & build instructions are not yet available. If you want, you can check out the [ISO Build workflow](https://github.com/Proman4713/Utile-OS/blob/main/.github/workflows/build-amd64.yml), which uses the NodeJS script, to replicate a similar process locally. If that works, feel free to contribute your solution to the repository.

## Plans
Before starting this project, I detailed a specific plan in [an older readme](./README.old.md#plan); however, I later realised that those plans weren't realistic due to some intricacies in how Ubuntu and apt/debian packages work. So I'm repurposing this section for plans. I write these plans when I think of them, and they are subject to change.

<details>
	<summary>Plans</summary>
	<ol>
		<li><strike>Make my own APT repository and Debian packages.</strike></li>
		<li><strike>Override upstream's <code>base-files</code> package to provide logos and release metadata.</strike></li>
		<li><strike>Change bashrc to use a lighter colour for the <code>user@computer</code> text.</strike></li>
		<li><strike>Either contribute my distribution's ASCII symbol to <code>fastfetch</code> or include it in a Debian package and set the <code>--logo</code> argument in a bashrc alias of <code>fastfetch</code>/<code>neofetch</code>.</strike></li>
		<li>Implement icon theme overrides to the Yaru theme to remove Ubuntu's trademarks from many places.</li>
		<li>Implement an installer that follows Utile OS's minimum-friction philosophy while also requiring the user to accept codecs to avoid legal grey areas.</li>
		<li>Implement my own Plymouth theme.</li>
		<li>Figure out a way to use/implement an equivalent of the <code>Customised Workspaces</code>, <code>Customize Clock on Lock Screen</code>, and <code>Lock screen background</code> extensions without cluttering the UI, so the desktop remains clean.</li>
		<li>Fully transition to using Debian packages (i.e. make more packages) to make modifications rather than manually executing commands.</li>
		<li><strike>Similarly, make a <code>utile-gnome-shell-extensions</code> package to install preferred extensions as system extensions and update them without needing the hacky <code>seed_extension</code> function in patch 000.</strike></li>
		<li><strike>Create a <code>utile-gnome-defaults</code> package for the gsettings/dconf changes.</strike></li>
		<li>Implement a custom upgrade solution to handle my own package repositories and hold Ubuntu upgrades until I finish syncing this project with upstream, so users can upgrade safely.</li>
		<li>Implement my own app store (packaged in Debian, not a Snap), which makes the Snap vs Debian issue less of a technical dilemma and more of a user-friendly choice. This app store must also improve the UI/UX over typical Linux app stores, which are mostly developed by people too tech-centric to think enough about the appeal of their UI. I would also like to allow developers to publish Debian-packaged apps to this store even if they don't come from the device's apt sources (which brings up the need for trust and security, to be discussed). This <i>could</i> be done by verifying a developer's identity and their app's safety, then adding the app's source repository <i>only</i> if the user chooses to install it. Could paid apps be a thing? I think we should generally learn from the macOS App Store.</li>
		<li><b>Support ARM in accordance with upstream. Currently, the <code>utile-wallpapers</code> package's arm64 version (which was indeed cool for providing different defaults depending on the user's hardware) is obsolete since we currently don't use arm <i>anywhere</i> in our distribution.</b></li>
		<li>Set up build farms through a web app for Utile OS's repositories so that packages don't have to be manually built for every architecture.</li>
		<li>Streamline feedback and bug reporting even more than Ubuntu Apport does. More on that is described in private notes; it is also related to the App Store (which would be made first).</li>
		<li>Implement native (and hopefully fancier) equivalents of Ubuntu snap system apps to avoid the over-dependence on the undocumented process of snap preseeding.</li>
	</ol>
</details>
<details>
	<summary>Debatable</summary>
	<ol>
		<li>Should I add ClamAV? Potentially with a custom extension to provide a GUI in the top bar/quick settings?</li>
		<li>Should I allow a custom wallpaper for the lock screen through extensions (potentially custom, to unify GDM login and lock screen)?</li>
		<li>Should I create an extension to reduce the size of the headerbar in GNOME, especially with fractional scaling? I think the fact that it is so <b><i>thick</b></i> right now shows how negligent GNOME is of more restricted users without 2,000" Ultrawide monitors. macOS <i>does</i> have thick window controls, but they are <i>floating;</i> GNOME takes the thickness of macOS controls and merges it with Windows's boxy headerbar layout.</li>
		<li>Should I include a pre-configured 'Dash2Dock Animated' extension? Is that too much like macOS in a way that it shouldn't be?</li>
		<li>Similarly, what about the 'Compiz alike magic lamp effect' extension? This could be too much, but maybe another extension that provides a springier minimise animation than the default?</li>
		<li>Should I include auto-cpufreq/thermald by default for better battery life? Perhaps with an extension to provide a UI for that as well?</li>
		<li>The average user does not have NAS devices and doesn't use <a href="https://ubuntu.com/server/docs/how-to/networking/install-nfs/">NFS</a>; should I disable the NetworkManager-wait-online.service to speed up boot time? What are the tradeoffs? Could I do it and perhaps provide a Settings toggle like 'Enable networking features on start-up' in whatever Settings app Utile OS will have (which could be GNOME Control Centre or something custom), so that users could easily be directed there instead of having to run terminal commands?</li>
	</ol>
</details>

## Why?
Utile OS started as an idea for my YouTube channel, [Codeswallop](https://youtube.com/@lots_of_codeswallop), where I plan to publish a series of video essays on Linux desktop system design and UX. For these videos, I'll need to research and address various pain points in the Linux desktop - with Ubuntu particularly serving as a starting point - that gradually accumulate into inexplicable frustration for a user transitioning from another OS. [Our website](https://utile-os-web.mailworker.workers.dev/) has a thorough description of Utile OS's goals.

The YouTube videos are meant to talk from a technically unrestricted perspective where I can present pain points and what could be done about them without consistently looking into why one solution is - or isn't - realistic from a technical/backend perspective. This will give me more room to address the vast majority of pain points from a UX-only perspective and provide a framework that a technical organisation can use to set goals and later consider technical possibilities or implementations to determine what is worth pursuing first.

If you want to read more from me about this, I'm pleased to say that there exists an unfortunate rant in the [old readme file](./README.old.md#why).

This project serves as a container for everything that I dare to try to address these pain points.

'**Utile**' (pronounced 'you-tile') is an old English word that meant 'Useful' and was popularly spoken before Shakespeare decided to first write the now-famous word. It comes from Middle French and still exists in French today. I specifically picked this word to highlight the helpfulness I want to provide with this project.

## Rights & Licensing
- This project is licensed under the well-known GPL v3, which covers all the code and shell scripts written here. The license is available inside [`LICENSE.md`](LICENSE.md).
- Media files available in [`resources/`](resources/) are licensed under Creative Commons, which covers images, designs, audio, video, and anything else in that folder as long as it includes the same Creative Commons license. The license is available at [`resources/LICENSE.md`](resources/LICENSE.md).
