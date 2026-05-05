# TODO: extension settings

# Add To Desktop, no idea why this isn't in the default Ubuntu install
seed_extension "add-to-desktop@tommimon.github.com" "https://extensions.gnome.org/extension-data/add-to-desktoptommimon.github.com.v16.shell-extension.zip"
seed_extension "blur-my-shell@aunetx" "https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v71.shell-extension.zip"
seed_extension "hidetopbar@mathieu.bidon.ca" "https://extensions.gnome.org/extension-data/hidetopbarmathieu.bidon.ca.v123.shell-extension.zip"
seed_extension "just-perfection-desktop@just-perfection" "https://extensions.gnome.org/extension-data/just-perfection-desktopjust-perfection.v36.shell-extension.zip"
#! commented out because I'm unsure of its functionality, especially considering that I'm definitely looking to add the 'Customised Workspaces' and 'Customize
#!	Clock on Lock Screen' extensions which involve having one wallpaper for each workspace
#* seed_extension "unlockDialogBackground@sun.wxg@gmail.com" "https://extensions.gnome.org/extension-data/unlockDialogBackgroundsun.wxggmail.com.v40.shell-extension.zip"
seed_extension "Vitals@CoreCoding.com" "https://extensions.gnome.org/extension-data/VitalsCoreCoding.com.v76.shell-extension.zip"
seed_extension "all-in-one-clipboard@NiffirgkcaJ.github.com" "https://extensions.gnome.org/extension-data/all-in-one-clipboardNiffirgkcaJ.github.com.v19.shell-extension.zip"

# Install GSConnect for phone link
install_packages gnome-shell-extension-gsconnect

#* CONFIGURE: Blur My Shell (--schemadir ~/.local/share/gnome-shell/extensions/blur-my-shell\@aunetx/schemas/)
# Add Overview pipeline
apply_gsettings "org.gnome.shell.extensions.blur-my-shell|pipelines|{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <15>, 'brightness': <0.7>, 'unscaled_radius': <15>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <70>, 'brightness': <0.5>, 'unscaled_radius': <70>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <16>}>}>]>}, 'pipeline_overview': {'name': <'Overview'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_45545059471727'>, 'params': <{'unscaled_radius': <20>, 'brightness': <0.5>}>}>]>}}"

# Set default values for folder backgrounds in the app grid
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.appfolder|brightness|0.32"
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.appfolder|sigma|3"
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.appfolder|style-dialogs|3"

# Set default values for application blur (by default Ptyxis is whitelisted)
	# Enable
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.applications|blur|true"
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.applications|dynamic-opacity|false"
	# Make it slightly more opaque than the default
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.applications|opacity|220"
	# Low blur intensity
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.applications|sigma|5"
	# Whitelist Ptyxis
	apply_gsettings "org.gnome.shell.extensions.blur-my-shell.applications|whitelist|['org.gnome.Ptyxis']"

# Disable blur on extensions we don't use
apply_gsettings "org.gnome.shell.extensions.blur-my-shell.coverflow-alt-tab|blur|false"
apply_gsettings "org.gnome.shell.extensions.blur-my-shell.window-list|blur|false"

# Change pipelines
apply_gsettings "org.gnome.shell.extensions.blur-my-shell.lockscreen|pipeline|'pipeline_overview'"
apply_gsettings "org.gnome.shell.extensions.blur-my-shell.overview|pipeline|'pipeline_overview'"
apply_gsettings "org.gnome.shell.extensions.blur-my-shell.screenshot|pipeline|'pipeline_overview'"

#* CONFIGURE: Hide Top Bar (--schemadir .local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/)
# Disable intellihide
apply_gsettings "org.gnome.shell.extensions.hidetopbar|enable-active-window|false"
apply_gsettings "org.gnome.shell.extensions.hidetopbar|enable-intellihide|false"

# Enable hot corner even with the top bar hidden
apply_gsettings "org.gnome.shell.extensions.hidetopbar|hot-corner|true"

# Show top bar when the mouse move towards the top of the screen, even when a fullscreen window is active, but don't automatically
#	open the overview just because the user moved the mouse
apply_gsettings "org.gnome.shell.extensions.hidetopbar|mouse-sensitive|true"
apply_gsettings "org.gnome.shell.extensions.hidetopbar|mouse-sensitive-fullscreen-window|true"
apply_gsettings "org.gnome.shell.extensions.hidetopbar|mouse-triggers-overview|false"

# Show the top bar in the overview
apply_gsettings "org.gnome.shell.extensions.hidetopbar|show-in-overview|true"

#* CONFIGURE: Just Perfection Desktop (--schemadir ~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/)
# Hide activities button, the entire existence of this button only serves to show the number of workspaces as well as act as a CTA to open the overview.
#	Regular users will most likely only use Super and Super+A, and power users know that hot corners exist, so that button is largely unneeded and this space may be
#	used better by the Vitals extension.
apply_gsettings "org.gnome.shell.extensions.just-perfection|activities-button|false"

# Show top bar in overview, in accordance with Hide Top Bar
apply_gsettings "org.gnome.shell.extensions.just-perfection|panel-in-overview|true"

# Boot to desktop rather than overview
apply_gsettings "org.gnome.shell.extensions.just-perfection|startup-status|0"

#! I will not add this, even though on my target system it is different from the default (0), because this stops the donation notification from appearing until
#!	a new version is released, which is probably wrong morally:
#? org.gnome.shell.extensions.just-perfection support-notifier-showed-version 36

#* CONFIGURE: Vitals (--schemadir ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com/schemas/)
#todo Show only memory and processor usage, I would later like to add temps to this
apply_gsettings "org.gnome.shell.extensions.vitals|hot-sensors|['_memory_usage_', '_processor_usage_']"

# I like the default icons better, but to make this more coherent with the rest of the system OOBE, I change the style to GNOME icons, which is closer to Ubuntu's
#	Yaru theme and to the iconography used in many GTK4 apps.
apply_gsettings "org.gnome.shell.extensions.vitals|icon-style|1"

# The extension still tries to run `gnome-system-monitor` by default, but the default on Ubuntu has become the 'Resources' app, so we change the command.
#	Big thanks to the author of the extension for making this possible.
apply_gsettings "org.gnome.shell.extensions.vitals|monitor-cmd|'resources'"

# Monitor the system GPU, and also allow the user to select static info about their GPU in the Vitals section of the top bar
apply_gsettings "org.gnome.shell.extensions.vitals|show-gpu|true"
apply_gsettings "org.gnome.shell.extensions.vitals|include-static-gpu-info|true"

# Show the Vitals extension on the far left, to replace the Activities button. Also disable the monitoring of other system components that would likely overwhelm
#	a non-technical user if they all showed in the Vitals popup from the top bar.
apply_gsettings "org.gnome.shell.extensions.vitals|position-in-panel|3"
apply_gsettings "org.gnome.shell.extensions.vitals|show-fan|false"
apply_gsettings "org.gnome.shell.extensions.vitals|show-network|false"
apply_gsettings "org.gnome.shell.extensions.vitals|show-storage|false"
apply_gsettings "org.gnome.shell.extensions.vitals|show-system|false"
apply_gsettings "org.gnome.shell.extensions.vitals|show-voltage|false"

#* CONFIGURE: All-in-one Clipboard (--schemadir ~/.local/share/gnome-shell/extensions/all-in-one-clipboard@NiffirgkcaJ.github.com/schemas/)
# Always show the main tab, even if the extension was triggered by a keyboard shortcut for a specific tab
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|always-show-main-tab|true"

#! Clear clipboard history at login. Debatable.
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|clear-data-at-login|true"

# Don't clear the recents anywhere else
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|clear-recent-emojis-at-login|false"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|clear-recent-gifs-at-login|false"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|clear-recent-kaomojis-at-login|false"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|clear-recent-symbols-at-login|false"

# Automatically past the whichever text/emoji/gif/kaomoji/symbol was selected by the user, I'm surprised this isn't the default. Also, don't unpin pinned clipboard
#	items when they're pasted. Also do not move old clipboard items to the top of the list if they're pasted again, this breaks the chronological sequence that the user
#	would likely have in their mind.
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|enable-auto-paste|true"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|unpin-on-paste|false"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|update-recency-on-copy|false"

# Use Tenor. And paste GIFs as images rather than links. Show up to 20 past GIFs.
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|gif-provider|'tenor'"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|gif-paste-behavior|1"
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|gif-recents-max-items|20"

# Hide top bar icon
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|hide-panel-icon|true"

# Use Super+V to open the clipboard, replacing the keybind for opening the notification/calendar popup. The default for emojis is Super+., which also replaces the
#	keybind for IBus emoji
apply_gsettings "org.gnome.shell.extensions.all-in-one-clipboard|shortcut-open-clipboard|['<Super>v']"

# Enable Extensions (except Blur My Shell):
apply_gsettings "org.gnome.shell|enabled-extensions|['hidetopbar@mathieu.bidon.ca', 'ding@rastersoft.com', 'ubuntu-dock@ubuntu.com', 'tiling-assistant@ubuntu.com', 'snapd-search-provider@canonical.com', 'web-search-provider@ubuntu.com', 'gsconnect@andyholmes.github.io', 'add-to-desktop@tommimon.github.com', 'just-perfection-desktop@just-perfection', 'Vitals@CoreCoding.com', 'all-in-one-clipboard@NiffirgkcaJ.github.com']"

apt-get autoremove -y --purge
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Compiling GLib schemas..."
glib-compile-schemas /usr/share/glib-2.0/schemas/

echo "Updating Dconf"
dconf update