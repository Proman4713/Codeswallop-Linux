# TODO: Brave default settings, default pinned apps, app grid layout, GSConnect

# Remove Rhythmbox - if its there - since we installed GNOME Music
apt-get remove -y rhythmbox

# We uninstalled Firefox as part of eliminating non-system snap packages, so we need a new default browser...
# Brave is going to be it. For no particular reason other than its ease of installation in addition to being my personal default
curl -fsS https://dl.brave.com/install.sh | sh

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

# Set font sizes to 9 rather than 11, which is roughly 125% smaller, then increase default fractional scaling to 125%. This is to make Chromium browsers look as big as
#	they do on macOS or Windows. Where the same display would usually require 125% display due to Windows' inherently smaller font sizes. So when a Chromium browser
#	sees 100% by default from Ubuntu, they scale to an equivalent of 100% on Windows which makes the scaling look way smaller than it should be.
#	this makes the default interface too small at 100%, just like it would be on Windows, prompting users to adjust it, just like they would do on Windows.
#!	EXPERIMENTAL, only tested on my system
apply_gsettings "org.gnome.desktop.interface|font-name|'Ubuntu Regular 9'"
apply_gsettings "org.gnome.desktop.interface|document-font-name|'Sans Regular 9'"
apply_gsettings "org.gnome.desktop.interface|monospace-font-name|'Ubuntu Mono Regular 9'"
apply_gsettings "org.gnome.desktop.wm.preferences|titlebar-font|'Ubuntu Bold 9'"
apply_gsettings "org.gnome.desktop.interface|font-hinting|'full'"

# Default neofetch
create_or_update_file_in_home ".bashrc" "$(cat << 'EOF'

alias neofetch="fastfetch"
EOF
)"

# Default Wallpapers
WP_DIR="/usr/share/backgrounds/codeswallop"
PROP_DIR="/usr/share/gnome-background-properties"
mkdir -p "$WP_DIR" "$PROP_DIR"

wget -qO "$WP_DIR/light.jpg" "https://raw.githubusercontent.com/Proman4713/Codeswallop-Linux/refs/heads/main/resources/Codeswallop%20Linux%20Wallpaper%20Light.png?raw=true"
wget -qO "$WP_DIR/dark.jpg" "https://github.com/Proman4713/Codeswallop-Linux/blob/main/resources/Codeswallop%20Linux%20Wallpaper%20Dark.png?raw=true"

#! XML file content got through Google & AI, not truly reliable
cat << EOF > "$WP_DIR/adaptive.xml"
<?xml version="1.0"?><!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers><wallpaper deleted="false"><name>Codeswallop Adaptive</name><filename>$WP_DIR/light.jpg</filename><filename-dark>$WP_DIR/dark.jpg</filename-dark><options>zoom</options><shade_type>solid</shade_type><pcolor>#000</pcolor><scolor>#000</scolor></wallpaper></wallpapers>
EOF

cat << EOF > "$PROP_DIR/codeswallop-wallpapers.xml"
<?xml version="1.0"?><!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false"><name>Codeswallop (Auto)</name><filename>$WP_DIR/light.jpg</filename><filename-dark>$WP_DIR/dark.jpg</filename-dark><options>zoom</options></wallpaper>
  <wallpaper deleted="false"><name>Codeswallop (Light)</name><filename>$WP_DIR/light.jpg</filename><options>zoom</options></wallpaper>
  <wallpaper deleted="false"><name>Codeswallop (Dark)</name><filename>$WP_DIR/dark.jpg</filename><options>zoom</options></wallpaper>
</wallpapers>
EOF

chmod 644 "$WP_DIR"/* "$PROP_DIR"/*

apply_gsettings \
    "org.gnome.desktop.background|picture-uri|'file://$WP_DIR/light.jpg'" \
    "org.gnome.desktop.background|picture-uri-dark|'file://$WP_DIR/dark.jpg'"

# GNOME Configurations
	# Ubuntu
		# Wartybrown theme
		apply_gsettings "org.gnome.desktop.interface|accent-color|'brown'"
		# Make the dock minimise/maximise apps when clicked there
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|click-action|'minimize-or-previews'"
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|extend-height|false"
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|dock-position|'BOTTOM'"
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|show-mounts|false"
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|show-trash|false"
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|show-apps-at-top|true"
		# Due to the fractional scaling setup, the Ubuntu Dock also needs to have a lower icon size (default 44)
		apply_gsettings "org.gnome.shell.extensions.dash-to-dock|dash-max-icon-size|35"

	# Muscle Memory: Windows users are used to Alt+Shift and Ctrl+Alt+Shift for switching input sources. Not only is this not the default in GNOME,
	#	it is actually impossible to achieve through the UI due to a bug that doesn't accept Alt+Shift_L.
	apply_gsettings "org.gnome.desktop.wm.keybindings|switch-input-source|['<Alt>Shift_L']"
	apply_gsettings "org.gnome.desktop.wm.keybindings|switch-input-source-backward|['<Primary><Alt>Shift_L']"

	# Muscle Memory: Windows users use Win+Shift+S to open the Snipping Tool
	apply_gsettings "org.gnome.shell.keybindings|show-screenshot-ui|['<Shift><Super>s']"

	# GNOME sometimes bugs certain extensions, like Hide Top Bar, that perfectly work with extension validation disabled
	apply_gsettings "org.gnome.shell|disable-extension-version-validation|true"

	# Make the cursor smaller, default is 24. This is to match the smaller font sizes we applied, so that it doesn't get too big with fractional scaling.
	apply_gsettings "org.gnome.desktop.interface|cursor-size|22"

	# Bind Super+E to open Files (Nautilus)
	apply_gsettings "org.gnome.settings-daemon.plugins.media-keys|home|['<Super>e']"

	# Remove IBus emoji keybind to leave room for the 'All-In-One Clipboard' extension we're going to install
	apply_gsettings "org.freedesktop.ibus.panel.emoji|unicode-hotkey|[]"

	# Default pinned apps
	apply_gsettings "org.gnome.shell|favorite-apps|['org.gnome.Nautilus.desktop', 'brave-browser.desktop', 'app.fotema.Fotema.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Music.desktop', 'libreoffice-impress.desktop', 'libreoffice-calc.desktop', 'libreoffice-writer.desktop', 'snap-store_snap-store.desktop', 'gnome-control-center.desktop']"