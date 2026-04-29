# Codeswallop-Linux
Container for all configurations, extensions, or experiments done to Ubuntu Desktop while I prepare my Linux video essays at https://youtube.com/@lots_of_codeswallop

Currently **not** designed or prepared for personal usage by anyone other than myself. I claim no liability over anything this project may do to your system as of now.

## Quick Start
- Status: Setup in progress, early development (Ubuntu-adjacent)
- Target OS: Ubuntu 26.04 LTS
- Target Audience: Ubuntu Desktop, Windows 11, macOS users
- Usage: Run compiled script or install ISO to get an enhanced version of Ubuntu with quality-of-life and aesthetic improvements

## Why?
'Codeswallop Linux' is not a real name meant to be said alongside 'Ubuntu' or 'Linux Mint' or 'Fedora'. Codeswallop is simply the name of my YouTube channel. And, before the end of this year, I plan to release a series of video essays related to Linux system and user experience design to research and address various pain points (tiny or large) in the Linux desktop - particularly Ubuntu as a starting point - that slowly accumulate to cause a total result of frustration for a user transitioning from another OS. I've personally seen some less eagle-eyed users of other OSs simply feel that there's 'something wrong' with the standard Ubuntu Desktop without being able to pinpoint many individual problems.

The YouTube videos are meant to talk from a technically-free perspective, meaning that I'm going to provide my points on what could be done to solve a problem without always looking into why it is or isn't realistic from a technical/backend perspective, this gives me more opportunity to address the significant majority of pain points as much as I can from a UX perspective, so that my videos could theoretically give a technical organisation a list of everything that's _recommended_ to do, and then let them think about the technical possibilities or implementation of each issue to determine which is worth pursuing first.

But, in the meantime, I'm going to act as that theoretical organisation, and will use this repository to create fixes and 'patches' (more on that later) that I find are easy enough for me to implement before, during, or after the production of my YouTube video essays.

Personally, I think Ubuntu is one of the most end-user compatible distributions out there. And I'd like to keep this a technical rather than a philosophical point of view.
If you're used to another distribution, desktop environment, or packaging solution, then this project is most likely not going to suit you. If, however, you don't like Ubuntu for philosophical or political reasons, your opinion may not affect this project at all, since the only philosophy behind it is: 'my dad should be able to use it without frustration.' And my dad definitely doesn't use middle-click paste.

Back to the point at hand: While Ubuntu is a very suitable starting point for end users, it - and many other distributions - often lack things that would seem trivial to a Windows or macOS user, regardless of the actual technical complications behind them.
I'm saying this as someone who transitioned to Ubuntu twice: Once from Windows 10 and again from 11. My aim with this project is to try to provide a much better starting point *without* compressing myself into Windows 10, 11 or macOS territory, which is something that some distros or desktop environments often do to immediately appeal to users of such operating systems. It's okay for Ubuntu or GNOME to have a unique design language and 'feel' to their user experience. But what I also don't want, though, is for Linux desktop - or this one specifically - to be buried under years of accumulated Power-User defaults and assumptions, or usage patterns and muscle memory configurations that completely break the expectations of Windows or macOS users. With Windows specifically being a main target, since macOS users usually have to re-learn certain things anyway when they transition to PC due to the slightly different keyboard layout on Apple devices.

This will most likely inevitably cause an increase in system resource consumption or a decrease in power efficiency over other Linux desktops. But my argument there is that whatever 'Codeswallop Linux' does, its resource usage will be far less than that of Windows (I do not use Apple devices often enough to provide a comparison there), for instance. But it should still be capable of looking and feeling just as good or maybe even better than other OSs. Resource consumption increase is inevitable given enough time, what with browsers and Electron apps eating up more RAM, and design and graphics standards increasing so that a modern UI, by Windows and especially macOS expectations, needs more resources than some of the current Linux desktops.

I hope I've explained myself well.

## Structure
This repository will be designed to follow a 'patch-like' system, similar to how Canonical applies git .patch files to modify GNOME shell and Mutter. In practice, this means that each task will be split into its own 'patch' .sh script. Additionally, the .sh scripts will work in a 'scaffolding' design rather than an 'importing' design. Essentially meaning that the scripts will be designed to install packages, edit individual settings, and make configurations step-by-step to better handle changes that are made in Ubuntu, GNOME, GNOME extensions, or anything else (including the possibility that a user may have customised their setup before running my script), by not brute forcing configs or dconf dumps onto the system.

The patches are planned to be 'compiled' in two ways:
1. Through a NodeJS codebase (or likely a CI/CD pipeline), which generates one big .sh file that is essentially a merge of all the individual 'patch' .sh files. This allows the entire project to be usable by someone in one terminal command, but also keeps it modular and easy to modify/contribute to.
2. Through a custom Ubuntu ISO created through [CUBIC](https://github.com/PJ-Singh-001/Cubic), where the script is run in the CUBIC environment (most likely in addition to other commands that make it more suitable to be an ISO and/or distinguishable from a regular Ubuntu ISO)

If it isn't already clear:
* This repository will build on top of Ubuntu Desktop, as it is, in my opinion, a balanced distribution, as well as the closest distro to what I'm trying to achieve.
* The script(s) in this repository will assume that it is the first thing you run on your system, even though the patch-like design should be mostly safe for any customisations that you apply before running the script.
* The script(s) assume a specific Ubuntu version. Again, even though the patch-like approach should avoid issues with upgrading. More info on versioning will be cleared up once there is actually something in this repository.

## Plan
In an ideal world, this would be its own Linux distribution. But the trouble, responsibility, and resources needed to achieve that obviously make it a task better left for those who can handle it (i.e. distribution maintainers). But, if I were to lay out a long-term plan that assumes unlimited resources, it would go like this:

### Ubuntu-adjacent
This is essentially what this repository, or 'Codeswallop Linux', is going to be at the start. A set of configurations, extensions, and high-level additions to the base Ubuntu Desktop that should keep things like smooth Ubuntu version upgrades without relying on me having to make my project up-to-date with the latest Ubuntu version. Basically, a project that runs *adjacent* to Ubuntu's development with no disruption to its users.

### Ubuntu-reliant
This is where, possibly, I - or anyone else working on this - will have made my own GTK/Libadwaita Apps to act as one-stop destinations to configure the things I add/make, my own forks of certain GNOME extensions, changes to system apps, etcetera.

This is where it starts to look more like a distribution. However, I outlined this stage because it is technically possible that the skill required to achieve these tasks is available without the resources required to make it a complete distribution. This is when I would probably shift to ISO-only (no .sh script), make Ubuntu upgrades disabled by default, and make some CLI or app that allows users to upgrade once I actually sync the project with changes 'upstream' (i.e., stock Ubuntu).

### Ubuntu-independent
This is the very unlikely stage where custom infrastructure should start to be added/made to turn this into an independent Ubuntu-*based* distribution. Customisations to the GNOME desktop, shell, Mutter, system apps, and other things that would essentially require separate package repositories from the Ubuntu ones. This is where the hurdles of an Ubuntu-reliant setup, like managing upgrades, would simply become part of the new distribution's release cycle, considering that it will have its own package repositories.

Now, what the name of this 'distro' should be, if not 'Codeswallop Linux'... I've got absolutely no idea.<br />
But that is, essentially, the ultimate goal...

## Rights & Licensing
This project is licensed under the well-known GPL v3, which includes all the code and shell scripts written here. However, media files, when added, will be licensed differently.

## Contributing
Contributing, for now, will be as simple as submitting an Issue or PR with a good description and valuable information. I currently see no need to restrict how contributions should be made.
