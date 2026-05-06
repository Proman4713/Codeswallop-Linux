# TODO: remove ubuntu-wallpapers (replaced by Utile. PPA needed),
# 	TODO: xul-ext-ubufox (courtesy of Pop!_OS's ISO repo). Also change Ubuntu icon in 'Show Applications' to either match gnome or contain a custom Utile icon.
#	TODO: Disable Ubuntu updates by default and provide an alternative command line utility to make sure that Utile is up to date
#	TODO: with upstream and is ready for the upgrade first. Essentially, we're already in the point of no return and we just have
#	TODO: to do things like this which make this a distribution, not a project.

if [ "$ENV_MODE" == "ISO" ]; then
	# TODO: do this with debian packages
	# New GRUB bootloader screen
	echo -e "\nConfiguring GRUB...\n"

	fonts_src_dir="/usr/share/grub/themes/utile/fonts"
	if [ -d "$fonts_src_dir" ] && [ -n "$(find "$fonts_src_dir" -maxdepth 1 -name '*.pf2' | head -n 1)" ]; then
		mkdir -p /boot/grub/fonts
		if ! cp "$fonts_src_dir"/*.pf2 /boot/grub/fonts/; then
			echo "Error: failed to copy GRUB fonts from $fonts_src_dir to /boot/grub/fonts/" >&2
			exit 1
		fi
	else
		echo "Error: GRUB font source directory '$fonts_src_dir' does not exist or contains no .pf2 files." >&2
		exit 1
	fi

	sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/utile/theme.txt"|' /etc/default/grub
	if ! grep -q "GRUB_THEME=" /etc/default/grub; then
		echo 'GRUB_THEME="/usr/share/grub/themes/utile/theme.txt"' >> /etc/default/grub
	fi

	sed -i 's|^#\?GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1080,auto|' /etc/default/grub
	if ! grep -q "^GRUB_GFXMODE=" /etc/default/grub; then
		echo 'GRUB_GFXMODE=1920x1080,auto' >> /etc/default/grub
	fi

	# APT Repository
	if ! curl -fsSL https://proman4713.github.io/Utile-OS-apt/public.key | sudo gpg --dearmor -o /etc/apt/keyrings/utile.gpg; then
		echo "Error: Failed to download or install Utile GPG key" >&2
		exit 1
	fi
	echo "deb [signed-by=/etc/apt/keyrings/utile.gpg] https://proman4713.github.io/Utile-OS-apt/ abstract main" | sudo tee /etc/apt/sources.list.d/utile.list
	apt_get_update

	# Wallpapers
	install_packages utile-wallpapers && apt-get remove --purge -y ubuntu-wallpapers ubuntu-wallpapers*

	# Release Info
	sudo rm -f /etc/os-release
	sudo rm -f /usr/lib/os-release

	# TODO: make utile-os-release debian package OR base-files and lsb/lsb-release forks from upstream
	cat <<EOF | sudo tee /usr/lib/os-release
PRETTY_NAME="Utile OS 26.04"
NAME="utile"
VERSION_ID="26.04"
VERSION="26.04 (Abstract Assembly)"
VERSION_CODENAME=abstract
ID=utile
ID_LIKE="ubuntu debian"
HOME_URL="https://github.com/Proman4713/Utile-OS"
SUPPORT_URL="https://github.com/Proman4713/Utile-OS/issues"
BUG_REPORT_URL="https://github.com/Proman4713/Utile-OS/issues"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=utile-logo
EOF
	sudo ln -srf /usr/lib/os-release /etc/os-release

	sudo rm -f /etc/lsb-release
	cat <<EOF | sudo tee /etc/lsb-release
DISTRIB_ID=UtileOS
DISTRIB_RELEASE=26.04
DISTRIB_CODENAME=abstract
DISTRIB_DESCRIPTION="Utile OS 26.04"
EOF

	# Add utile-logo
	# TODO: make utile-os-logos debian package OR replace base-files as well
	download_logo() {
		local dest="$1" url="$2"
		if ! wget -qO "$dest" "$url"; then
			echo "Error: Failed to download $url" >&2
			exit 1
		fi
	}

	download_logo "/usr/share/pixmaps/utile-logo.svg" "https://raw.githubusercontent.com/Proman4713/Utile-OS/refs/heads/main/resources/Utile%20Square%20Logo.svg"
	# For GNOME Control Centre (https://gitlab.gnome.org/GNOME/gnome-control-center/-/blob/main/panels/system/about/cc-about-page.c?ref_type=heads):
	download_logo "/usr/share/pixmaps/utile-logo-text.png" "https://raw.githubusercontent.com/Proman4713/Utile-OS/refs/heads/main/resources/Utile%20Transparent%20Lockup.png"
	download_logo "/usr/share/pixmaps/utile-logo-text.svg" "https://raw.githubusercontent.com/Proman4713/Utile-OS/refs/heads/main/resources/Utile%20Transparent%20Lockup.svg"
	download_logo "/usr/share/pixmaps/utile-logo-text-dark.png" "https://raw.githubusercontent.com/Proman4713/Utile-OS/refs/heads/main/resources/Utile%20Transparent%20Lockup.png"
	download_logo "/usr/share/pixmaps/utile-logo-text-dark.svg" "https://raw.githubusercontent.com/Proman4713/Utile-OS/refs/heads/main/resources/Utile%20Transparent%20Lockup.svg"
fi