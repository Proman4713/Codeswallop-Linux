# Apps
# Pretty unneeded for the average user, shotwell doesn't look good, and the games are unnecessary bloat for most.
#	Not even Windows 11 comes with things other than Solitaire nowadays...
apt-get purge -y transmission-gtk transmission-common shotwell shotwell-common gnome-mines gnome-sudoku gnome-mahjongg aisleriot remmina* simple-scan

# TODO: Build Amberol from source since it looks better than gnome music but is sadly only available as Flatpak
# TODO: Fotema is a gallery app, something that is surprisingly missing from stock Ubuntu, also only available as Flatpak
install_packages gdebi gnome-tweaks gnome-shell-extension-manager gnome-calendar gnome-music showtime gnome-snapshot deja-dup

# Tools
install_packages htop fastfetch curl wget git unzip

# Canberra for startup sound
install_packages libcanberra-gtk3-module libcanberra-gtk-module gnome-session-canberra || echo "Warning: Some Canberra modules not found, moving on..."

# LibreOffice
	#! LICENSE AGREEMENT
	echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
install_packages libreoffice