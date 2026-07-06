# TODO: Change Ubuntu icon in 'Show Applications' to either match gnome or contain a custom Utile icon.
#	TODO: Disable Ubuntu updates by default and provide an alternative command line utility to make sure that Utile is up to date
#	TODO: with upstream and is ready for the upgrade first.

if [ "$ENV_MODE" == "ISO" ]; then
	# APT Repository, GPG key is later overridden by the `utile-keyring` package depended on by `utile-desktop`, this is just here so that our first installs are trusted
	if ! curl -fsSL https://proman4713.github.io/Utile-OS-apt/public.key | sudo gpg --dearmour -o /usr/share/keyrings/utile-repository-keyring.gpg; then
		echo "Error: Failed to download or install Utile GPG key" >&2
		exit 1
	fi

	# Use deb822 source format in /etc/apt/sources.list.d/utile.sources
	(cat << 'EOF'
## Utiie distribution repository
##
## Components: These are the components that exist inside Utile OS's package repositories
##   main  - Functional packages that make Utile OS what it is.
##   universe    - Community maintained packages.
##   upstream  - Versions of upstream Ubuntu packages that are tuned to work best with Utile OS.
##
## See the sources.list(5) manual page for further settings.
Types: deb
URIs: http://proman4713.github.io/Utile-OS-apt/
Suites: abstract
Components: main upstream universe
Signed-By: /usr/share/keyrings/utile-repository-keyring.gpg

EOF
) | sudo tee /etc/apt/sources.list.d/utile.sources

	# Prioritise Utile packages over Ubuntu ones
	(cat << 'EOF'
Package: *
Pin: origin proman4713.github.io
Pin-Priority: 750
EOF
) | sudo tee /etc/apt/preferences.d/utile.pref

	# Reflect the changes
	apt_get_update

	# Release Info and logos
	if ! apt-get install --only-upgrade -y base-files; then
		echo "Error: Failed to upgrade base-files package" >&2
		exit 1
	fi
	echo "Release $(lsb_release -a)\nCodename: $(lsb_release -cs)"

	# Desktop metapackage (GRUB Theme, Wallpapers, GNOME extensions, default configurations, etc.)
	chmod -x /etc/grub.d/30_os-prober
	export GRUB_DISABLE_OS_PROBER=true
	# Also remove all ubuntu-wallpapers packages, ubuntu-wallpapers is already conflicted by utile-wallpapers, which should uninstall the main package,
	#	However, release-specific packages such as ubuntu-wallpapers-{noble,resolute,stonking} also exist.
	install_packages utile-desktop && apt-get remove --purge -y ubuntu-wallpapers ubuntu-wallpapers*
	chmod +x /etc/grub.d/30_os-prober
fi