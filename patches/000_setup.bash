set -exuo pipefail # Strict

# Ensure we are running as root, obviously
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)"
  exit
fi

# Determine environment
# 	ISO: The chroot environment on the base Ubuntu ISO already runs changes to system-wide configs, we don't need to care about user preferences.
#	Post-Install: If a user runs this script after they install their system, then only changing system defaults doesn't help, we also have to change their
#	current settings.
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && getent passwd "$SUDO_USER" >/dev/null 2>&1; then
	ENV_MODE="POST"
	TARGET_USER="$SUDO_USER"
	echo "Environment: Post-Install (Configuring for future users AND $TARGET_USER)"
else
	ENV_MODE="ISO"
	echo "Environment: Ubuntu ISO Chroot (Configuring for future users only)"
fi

install_packages() {
	apt-get install -y "$@"
}

apt_get_update() {
	apt-get update || echo "Some repos failed, but we should be still fine..."
}

export DEBIAN_FRONTEND=noninteractive

apt_get_update