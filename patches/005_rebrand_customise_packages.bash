# TODO: Change Ubuntu icon in 'Show Applications' to either match gnome or contain a custom Utile icon.
#	TODO: Disable Ubuntu updates by default and provide an alternative command line utility to make sure that Utile is up to date
#	TODO: with upstream and is ready for the upgrade first.

if [ "$ENV_MODE" == "ISO" ]; then
	# APT Repository
	if ! curl -fsSL https://proman4713.github.io/Utile-OS-apt/public.key | sudo gpg --dearmor -o /etc/apt/keyrings/utile.gpg; then
		echo "Error: Failed to download or install Utile GPG key" >&2
		exit 1
	fi
	echo "deb [signed-by=/etc/apt/keyrings/utile.gpg] https://proman4713.github.io/Utile-OS-apt/ abstract main upstream universe" | sudo tee /etc/apt/sources.list.d/utile.list
	apt_get_update

	# Release Info and logos
	if ! apt-get install --only-upgrade -y base-files; then
		echo "Error: Failed to upgrade base-files package" >&2
		exit 1
	fi
	echo "Release $(lsb_release -a)\nCodename: $(lsb_release -cs)"

	# Desktop metapackage (GRUB Theme, Wallpapers, etc.)
	chmod -x /etc/grub.d/30_os-prober
	# shellcheck disable=SC2034
	GRUB_DISABLE_OS_PROBER=true
	install_packages utile-desktop && apt-get remove --purge -y ubuntu-wallpapers ubuntu-wallpapers*
	chmod +x /etc/grub.d/30_os-prober
fi

apt-get autoremove -y --purge
apt-get clean