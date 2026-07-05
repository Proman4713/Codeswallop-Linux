set -exuo pipefail # Strict

# Ensure we are running as root, obviously
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)"
  exit
fi

# Determine environment
# 	ISO: The chroot environment on the base Ubuntu ISO already runs changes to system-wide configs, we don't need to care about user preferences.
#	Post-Install: If a user runs this script after they install their system, then only changing system defaults doesn't help, we also have to change their
#	current settings.
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && getent passwd "$SUDO_USER" >/dev/null 2>&1; then
	ENV_MODE="POST"
	TARGET_USER="$SUDO_USER"
	echo "Environment: Post-Install (Configuring for future users AND $TARGET_USER)"
else
	ENV_MODE="ISO"
	echo "Environment: Ubuntu ISO Chroot (Configuring for future users only)"
fi

install_packages() {
	apt-get install -y "$@"
}

apt_get_update() {
	apt-get update || echo "Some repos failed, but we should be still fine..."
}

export DEBIAN_FRONTEND=noninteractive

(cat << 'EOF'
# Ubuntu sources have moved to the /etc/apt/sources.list.d/ubuntu.sources
# file, which uses the deb822 format. Use deb822-formatted .sources files
# to manage package sources in the /etc/apt/sources.list.d/ directory.
# See the sources.list(5) manual page for details.
EOF
) | sudo tee /etc/apt/sources.list

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

# Seeding happens here now, since Debootstrap doesn't install recommends of packages
if [ "$ENV_MODE" == "ISO" ]; then
	install_packages base-files \
	curl \
	deja-dup \
	dracut \
	ffmpegthumbnailer \
	gdebi \
	git \
	gnome-calendar \
	gnome-music \
	gnome-session-canberra \
	gnome-shell-extension-manager \
	gnome-snapshot \
	gnome-tweaks \
	gparted \
	grub-common \
	grub-gfxpayload-lists \
	grub-pc \
	grub2-common \
	gst-audio-thumbnailer \
	gst-video-thumbnailer \
	htop \
	libfuse2t64 \
	linux-generic-hwe-24.04 \
	linux-generic-hwe-26.04 \
	showtime \
	snapd \
	sssd \
	ubuntu-desktop-minimal \
	ubuntu-restricted-extras \
	ubuntu-standard \
	unzip \
	wget
fi