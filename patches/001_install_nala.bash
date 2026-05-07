install_packages nala

echo "Configuring apt command to use nala..."

# TODO: debian package
create_or_update_file_in_home ".bashrc" "$(cat << 'EOF'

apt() {
	echo -e "\e[31mUtile OS uses nala for 'apt' commands. If you want to use apt: Modify your .bashrc, use sudo, or use apt-get.\e[0m"
	if [[ "$1" == "history" || "$1" == "list" || "$1" == "search" || "$1" == "show" ]]; then
		nala "$@"
	elif [[ "$1" == "autoclean" || "$1" == "reinstall" || "$1" == "satisfy" || "$1" == "source" || "$1" == "edit-sources" ]]; then
		sudo apt "$@"
	else
		sudo nala "$@"
	fi
}
EOF
)"