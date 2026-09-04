#^ Apps
# Pretty unneeded for the average user, shotwell doesn't look good, and the games are unnecessary bloat for most.
#	Not even Windows 11 comes with things other than Solitaire nowadays...
apt-get purge -y transmission-gtk transmission-common \
				shotwell shotwell-common \
				gnome-mines gnome-sudoku gnome-mahjongg aisleriot gnome-terminal gnome-music \
				remmina* \
				simple-scan \
				usb-creator* \
				rhythmbox \
				wbrazilian wbritish wfrench witalian wngerman wogerman wportuguese wspanish wswiss \
				xorriso \
				ubuntu-desktop \
				xul-ext-ubufox # Courtesy of Pop!_OS's ISO Builder repo

#! Actually not an accessibility risk much! Only some languages are there, which means that the system somehow would've done something else if I chose Arabic, for example.
#!	So it seems like the installer somehow does something else depending on the language chosen for the installation.
#!
#! NOTE: Ubuntu preinstalls certain languages based on their user base; I already mentioned in the project documentation that we could potentially do something cleverer;
#!	however, should font and ibus packages be removed after all? They aren't language packs...
apt-get purge -y fonts-arphic-ukai \
				fonts-arphic-uming \
				gnome-user-docs-de \
				gnome-user-docs-es \
				gnome-user-docs-fr \
				gnome-user-docs-it \
				gnome-user-docs-pt \
				gnome-user-docs-ru \
				gnome-user-docs-zh-hans \
				ibus-chewing \
				ibus-libpinyin \
				ibus-m17n \
				ibus-table-cangjie \
				ibus-table-quick-classic \
				ibus-table-wubi \
				language-pack-de \
				language-pack-de-base \
				language-pack-es \
				language-pack-es-base \
				language-pack-fr \
				language-pack-fr-base \
				language-pack-gnome-de \
				language-pack-gnome-de-base \
				language-pack-gnome-es \
				language-pack-gnome-es-base \
				language-pack-gnome-fr \
				language-pack-gnome-fr-base \
				language-pack-gnome-it \
				language-pack-gnome-it-base \
				language-pack-gnome-pt \
				language-pack-gnome-pt-base \
				language-pack-gnome-ru \
				language-pack-gnome-ru-base \
				language-pack-gnome-zh-hans \
				language-pack-gnome-zh-hans-base \
				language-pack-it \
				language-pack-it-base \
				language-pack-pt \
				language-pack-pt-base \
				language-pack-ru \
				language-pack-ru-base \
				language-pack-zh-hans \
				language-pack-zh-hans-base

#^ English Language packages
install_packages language-pack-en \
				language-pack-en-base \
				language-pack-gnome-en \
				language-pack-gnome-en-base

# TODO: Fotema is a gallery app, something that is surprisingly missing from stock Ubuntu, also only available as Flatpak
# Our default music player is now Utile Music, which is provided by utile-desktop.
install_packages \
				gnome-tweaks gnome-shell-extension-manager \
				gnome-calendar showtime gnome-snapshot \
				deja-dup

#^ Tools
install_packages htop curl wget git unzip

#^ Canberra for startup sound
install_packages libcanberra-gtk3-module libcanberra-gtk-module gnome-session-canberra || echo "Warning: Some Canberra modules not found, moving on..."

#^ LibreOffice
	#! LICENSE AGREEMENT
	echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
	install_packages libreoffice