# TODO: Brave default settings, app grid layout

# We uninstalled Firefox as part of eliminating non-system snap packages, so we need a new default browser...
# Brave is going to be it. For no particular reason other than its ease of installation in addition to being my personal default
curl https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg |\
	sudo install -DTm644 /dev/stdin "/usr/share/keyrings/brave-browser-archive-keyring.gpg"
curl "https://brave-browser-apt-release.s3.brave.com/brave-browser.sources" |\
    sudo install -DTm644 /dev/stdin "/etc/apt/sources.list.d/brave-browser-release.sources"
apt_get_update
install_packages brave-browser

# Configure Brave command-line args
BRAVE_DESKTOP="/usr/share/applications/brave-browser.desktop"
if [ -f "$BRAVE_DESKTOP" ]; then
	echo "Applying custom flags to Brave .desktop file..."

	# Add Wayland support, middle-click to scroll, and hopefully (untested) better touchpad support
	sed -i 's|Exec=/usr/bin/brave-browser-stable|Exec=/usr/bin/brave-browser-stable --enable-blink-features=MiddleClickAutoscroll --enable-features=UseOzonePlatform,TouchpadOverscrollHistoryNavigation,VaapiVideoDecoder --ozone-platform=wayland|g' "$BRAVE_DESKTOP"

	# Set Brave as the default handler for web browser schemes
	# This is a system-wide association
	update-desktop-database /usr/share/applications
else
	echo "Warning: Brave .desktop file not found at $BRAVE_DESKTOP"
fi