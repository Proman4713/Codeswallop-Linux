install_packages nala

echo "Configuring apt command to use nala..."

create_or_update_file_in_home ".bashrc" "$(cat << 'EOF'

apt() {
	echo -e "\e[31mThe apt command has been configured to use nala as a backend. If you want to use standard apt: Modify your .bashrc, use sudo apt or use apt-get.\e[0m"
	sudo nala "$@"
}
EOF
)"