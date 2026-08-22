set -exuo pipefail # Strict

# Ensure we are running as root, obviously
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit
fi

# Determine environment
# 	ISO: This is the chroot environment used to build the ISO, it already runs changes globally; we don't need to care about user preferences.
#	Post-Install: If a user runs this script after they install their system, then only changing system defaults doesn't help, we also have to change their
#	current settings. (HEAVILY NEGLECTED AS OF NOW)
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && getent passwd "$SUDO_USER" >/dev/null 2>&1; then
	ENV_MODE="POST"
	TARGET_USER="$SUDO_USER"
	echo "Environment: Post-Install (Configuring for future users AND $TARGET_USER)"
else
	ENV_MODE="ISO"
	echo "Environment: Ubuntu ISO Chroot (Configuring for future users only)"
fi

# Wrapper to avoid useless hiccups due to missing -y
install_packages() {
	apt-get install -y "$@"
}

# Presumably added due to an issue with installing libcanberra
apt_get_update() {
	apt-get update || echo "Some repos failed, but we should be still fine..."
}

# To avoid any interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Add the sources.list file usually found on Ubuntu systems but wouldn't be the same on a debootstrap'd system (it isn't created by any apt
#	package, and so will presumably have the sources provided to debootstrap; we need to change it in all cases)
(cat << 'EOF'
# Ubuntu sources have moved to the /etc/apt/sources.list.d/ubuntu.sources
# file, which uses the deb822 format. Use deb822-formatted .sources files
# to manage package sources in the /etc/apt/sources.list.d/ directory.
# See the sources.list(5) manual page for details.
EOF
) | sudo tee /etc/apt/sources.list

# Add the standard Ubuntu 26.04 repositories, this wouldn't be there at all on a debootstrap'd system, which could cause some issues down the
#	line since there is no guarantee of debootstrap figuring out all the correct Suites and URIs.
(cat << 'EOF'
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.

## Ubuntu distribution repository
##
## The following settings can be adjusted to configure which packages to use from Ubuntu.
## Mirror your choices (except for URIs and Suites) in the security section below to
## ensure timely security updates.
##
## Types: Append deb-src to enable the fetching of source package.
## URIs: A URL to the repository (you may add multiple URLs)
## Suites: The following additional suites can be configured
##   <name>-updates   - Major bug fix updates produced after the final release of the
##                      distribution.
##   <name>-backports - software from this repository may not have been tested as
##                      extensively as that contained in the main release, although it includes
##                      newer versions of some applications which may provide useful features.
##                      Also, please note that software in backports WILL NOT receive any review
##                      or updates from the Ubuntu security team.
## Components: Aside from main, the following components can be added to the list
##   restricted  - Software that may not be under a free license, or protected by patents.
##   universe    - Community maintained packages. Software in this repository receives maintenance
##                 from volunteers in the Ubuntu community, or a 10 year security maintenance
##                 commitment from Canonical when an Ubuntu Pro subscription is attached.
##   multiverse  - Community maintained of restricted. Software from this repository is
##                 ENTIRELY UNSUPPORTED by the Ubuntu team, and may not be under a free
##                 licence. Please satisfy yourself as to your rights to use the software.
##                 Also, please note that software in multiverse WILL NOT receive any
##                 review or updates from the Ubuntu security team.
##
## See the sources.list(5) manual page for further settings.
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: resolute resolute-updates resolute-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

## Ubuntu security updates. Aside from URIs and Suites,
## this should mirror your choices in the previous section.
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: resolute-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
) | sudo tee /etc/apt/sources.list.d/ubuntu.sources

apt_get_update

# Package seeding happens here now instead of in the host (with debootstrap), since debootstrap doesn't install recommends of packages...
#	These packages are specified from the standard Ubuntu seeds (e.g., https://static-reports.ubuntu.com/seeds/ubuntu.resolute/desktop-minimal),
#	the `*.manifest.full` files in the `casper/` directory on official ISOs, as well as the packages found in live Ubuntu environments.
if [ "$ENV_MODE" == "ISO" ]; then
	install_packages adcli \
	base-files \
	btrfs-progs \
	dracut \
	efibootmgr \
	file-roller \
	finalrd \
	gawk \
	gdb \
	git \
	gparted \
	grub-common \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	grub-efi-amd64-unsigned \
	grub-gfxpayload-lists \
	grub-pc \
	grub2-common \
	gst-audio-thumbnailer \
	gst-video-thumbnailer \
	keyutils \
	linux-generic-hwe-24.04 \
	linux-generic-hwe-26.04 \
	linux-libc-dev \
	localechooser-data \
	lvm2 \
	m17n-db \
	mdadm \
	media-player-info \
	python3-pil \
	realmd \
	shim-signed \
	snapd \
	sssd \
	ubuntu-desktop-minimal \
	ubuntu-restricted-extras \
	ubuntu-standard \
	user-setup \
	wget \
	xfsprogs \
	xorriso \
	zfsutils-linux
fi