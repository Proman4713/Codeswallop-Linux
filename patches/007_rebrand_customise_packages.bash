# TODO: remove ubuntu-wallpapers (replaced by Utile. PPA needed),
# 	TODO: xul-ext-ubufox (courtesy of Pop!_OS's ISO repo). Also change Ubuntu icon in 'Show Applications' to either match gnome or contain a custom Utile icon.
#	TODO: Disable Ubuntu updates by default and provide an alternative command line utility to make sure that Utile is up to date
#	TODO: with upstream and is ready for the upgrade first. Essentially, we're already in the point of no return and we just have
#	TODO: to do things like this which make this a distribution, not a project.

if [ "$ENV_MODE" == "ISO" ]; then
	# New GRUB bootloader screen
	echo -e "\nConfiguring GRUB...\n"

	mkdir -p /boot/grub/fonts
	cp /usr/share/grub/themes/utile/fonts/*.pf2 /boot/grub/fonts/

	sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/utile/theme.txt"|' /etc/default/grub
	if ! grep -q "GRUB_THEME=" /etc/default/grub; then
		echo 'GRUB_THEME="/usr/share/grub/themes/utile/theme.txt"' >> /etc/default/grub
	fi

	sed -i 's|^#GRUB_DISTRIBUTOR=.*|GRUB_DISTRIBUTOR="utile"|' /etc/default/grub
	if ! grep -q "GRUB_DISTRIBUTOR=" /etc/default/grub; then
		echo 'GRUB_DISTRIBUTOR="utile"' >> /etc/default/grub
	fi

	sed -i 's|^GRUB_GFXMODE=.*|GRUB_GFXMODE=1920x1080,auto|' /etc/default/grub
fi