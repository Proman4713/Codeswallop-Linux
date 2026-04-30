set -exuo pipefail # Strict

# Ensure we are running as root, obviously
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo)"
  exit
fi

# Determine environment
# 	CUBIC: The terminal environment in CUBIC already runs changes to system-wide configs, we don't 	need to care about user preferences.
#	Post-Install: If a user runs this script after they install their system, then only changing system defaults doesn't help, we also have to change their current settings.
if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ] && getent passwd "$SUDO_USER" >/dev/null 2>&1; then
	ENV_MODE="POST"
	TARGET_USER="$SUDO_USER"
	TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
	echo "Environment: Post-Install (Configuring for future users AND $TARGET_USER)"
else
	ENV_MODE="CUBIC"
	echo "Environment: Cubic Chroot (Configuring for future users only)"
fi

install_packages() {
	apt-get install -y "$@"
}

create_or_update_file_in_home() {
	local target_file="$1"
    local file_content="$2"

    echo "Adding file /etc/skel/$target_file..."
    
    # Ensure the directory exists in skel (e.g., if writing to .config/foo/settings)
    mkdir -p "/etc/skel/$(dirname "$target_file")"
    echo "$file_content" >> "/etc/skel/$target_file"

    # If post-install, apply the same changes to the active user
    if [ "$ENV_MODE" == "POST" ]; then
        echo "Applying config to $TARGET_HOME/$target_file..."
        
        # Ensure the directory exists in the user's home as well
        mkdir -p "$TARGET_HOME/$(dirname "$target_file")"
        echo "$file_content" >> "$TARGET_HOME/$target_file"
        
        # Hand over ownership of the new files to the user
        chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/$(dirname "$target_file")"
    fi
}

# `gsettings` command alternative to set both system-wide and current user defaults
# Usage: apply_gsettings <schema> <key> <value>
apply_gsettings() {
    local settings=("$@")
    [[ ${#settings[@]} -eq 0 ]] && return
    
    local override_file="/usr/share/glib-2.0/schemas/90_custom_defaults.gschema.override"
    echo "Applying GSettings..."

    for entry in "${settings[@]}"; do
        # Split string by pipe character: schema|key|value
        IFS='|' read -r schema key value <<< "$entry"
        
        # System-wide Override
        if ! grep -q "\[$schema\]" "$override_file" 2>/dev/null; then
            echo -e "\n[$schema]" >> "$override_file"
        fi
        echo "$key=$value" >> "$override_file"

        # Apply to Current User Session too in POST
        if [[ "$ENV_MODE" == "POST" ]]; then
            sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$TARGET_USER")/bus" \
            gsettings set "$schema" "$key" "$value" || true
        fi
    done

    echo "Compiling GLib schemas..."
    glib-compile-schemas /usr/share/glib-2.0/schemas/
}

# Usage: seed_extension "UUID" "ZIP_URL"
# Seed extensions rather than including them as System Extensions so that GNOME updates them normally after my initial seed
seed_extension() {
    local uuid="$1"
    local zip_url="$2"
    local temp_dir="/tmp/ext_$uuid"
    local target_path=".local/share/gnome-shell/extensions/$uuid"

    echo "Seeding extension for updateability: $uuid"
    
    # Download and extract to a temp
    mkdir -p "$temp_dir"
    wget -qO "/tmp/$uuid.zip" "$zip_url"
    unzip -qo "/tmp/$uuid.zip" -d "$temp_dir"

    # Copy to skel and current user if POST
    mkdir -p "/etc/skel/$(dirname "$target_path")"
    cp -r "$temp_dir" "/etc/skel/$target_path"
    
    if [ "$ENV_MODE" == "POST" ]; then
        mkdir -p "$TARGET_HOME/$(dirname "$target_path")"
        cp -r "$temp_dir" "$TARGET_HOME/$target_path"
        chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local"
    fi

    # Cleanup
    rm -rf "$temp_dir" "/tmp/$uuid.zip"
}

export DEBIAN_FRONTEND=noninteractive
apt-get update || echo "Some repos failed, but we should be still fine..."