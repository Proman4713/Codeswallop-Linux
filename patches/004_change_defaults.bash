# TODO: Brave default settings, app grid layout

# We uninstalled Firefox as part of eliminating non-system snap packages, so we need a new default browser...
# Brave is going to be it. For no particular reason other than its ease of installation in addition to being my personal default
curl https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg |\
	sudo install -DTm644 /dev/stdin "/usr/share/keyrings/brave-browser-archive-keyring.gpg"
curl "https://brave-browser-apt-release.s3.brave.com/brave-browser.sources" |\
    sudo install -DTm644 /dev/stdin "/etc/apt/sources.list.d/brave-browser-release.sources"
apt_get_update
install_packages brave-browser
#
#	! Running Brave on the live ISO does not work, and gives this output:
#		[6611:6611:0804/130457.772606:FATAL:sandbox/linux/services/credentials.cc:131] Check failed: . : Permission denied (13)
#		[0804/130458.000648:ERROR:third_party/crashpad/crashpad/util/file/file_io_posix.cc:145] open /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: No such file or directory (2)
#		[0804/130458.000853:ERROR:third_party/crashpad/crashpad/util/file/file_io_posix.cc:145] open /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: No such file or directory (2)
#		/usr/bin/brave-browser: line 30: 6611 Trace/breakpoint trap	(core dumped) "$HERE/brave" "$@"
#
#	https://askubuntu.com/questions/1533668/upgrading-to-ubuntu-24-04-lts-breaks-chrome-apparmor-issue is a potential fix
#
sudo aa-status
sudo systemctl enable apparmor # TODO: move to patch 006

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