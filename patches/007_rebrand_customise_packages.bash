# TODO: remove ubuntu-wallpapers (replaced by Utile. PPA needed),
# 	TODO: xul-ext-ubufox (courtesy of Pop!_OS's ISO repo). Also change Ubuntu icon in 'Show Applications' to either match gnome or contain a custom Utile icon.
#	TODO: Disable Ubuntu updates by default and provide an alternative command line utility to make sure that Utile is up to date
#	TODO: with upstream and is ready for the upgrade first. Essentially, we're already in the point of no return and we just have
#	TODO: to do things like this which make this a distribution, not a project.

if [ "$ENV_MODE" == "ISO" ]; then
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

	sed -i 's|^#GRUB_DISTRIBUTOR=.*|GRUB_DISTRIBUTOR="utile"|' /etc/default/grub
	if ! grep -q "GRUB_DISTRIBUTOR=" /etc/default/grub; then
		echo 'GRUB_DISTRIBUTOR="utile"' >> /etc/default/grub
	fi

	sed -i 's|^#\?GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1080,auto|' /etc/default/grub
	if ! grep -q "^GRUB_GFXMODE=" /etc/default/grub; then
		echo 'GRUB_GFXMODE=1920x1080,auto' >> /etc/default/grub
	fi
fi