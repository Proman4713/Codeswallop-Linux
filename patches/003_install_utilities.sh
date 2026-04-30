# Apps
# TODO: Build Amberol from source since it looks better than gnome music but is sadly only available as Flatpak
# TODO: Fotema is a gallery app, something that is surprisingly missing from stock Ubuntu, also only available as Flatpak
install_packages gdebi gnome-tweaks gnome-shell-extension-manager gnome-calendar gnome-clocks gnome-music showtime loupe

# Tools
install_packages htop fastfetch curl wget git unzip

# Canberra for startup sound
install_packages libcanberra-gtk3-module libcanberra-gtk-module gnome-session-canberra

# LibreOffice
if [ "$ENV_MODE" == "POST" ]; then
	install_packages libreoffice
fi

# Prevent libreoffice from being uninstalled in minimal install
MINIMAL_LIST="/usr/share/ubiquity/minimal-install"
if [ -f "$MINIMAL_LIST" ]; then
    sed -i '/libreoffice/d' "$MINIMAL_LIST"
fi