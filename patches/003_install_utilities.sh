# Apps
# TODO: Build Amberol from source since it looks better than gnome music but is sadly only available as Flatpak
# TODO: Fotema is a gallery app, something that is surprisingly missing from stock Ubuntu, also only available as Flatpak
install_packages gdebi gnome-tweaks gnome-shell-extension-manager gnome-calendar gnome-clocks gnome-music showtime loupe

# Tools
install_packages htop fastfetch curl wget git unzip

# LibreOffice

if [ "$ENV_MODE" == "POST" ]; then
	install_packages libreoffice
fi
# TODO: REMOVE LIBREOFFICE FROM PURGE LIST IN UBUNTU MINIMAL INSTALLATION FOR CUBIC