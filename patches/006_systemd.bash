# Install casper so that the initramfs is updated accordingly, will later uninstall through chroot after copying the
#	INITRD and VMLINUZ files from the chroot. This could fix the problem with SystemD's
#	`[FAILED] Failed to start initrd-switch-root.service - Switch Root.` error. Not that I did any research on it,
#	but I found 
#	THIS BY NATURE REMOVES DRACUT BECAUSE IT DEPENDS ON INITRAMFS-TOOLS
install_packages casper
install_packages cryptsetup cryptsetup-bin cryptsetup-initramfs

export CASPER_GENERATE_UUID=1
export LAYERFS_PATH=filesystem.squashfs
mkdir -p "etc/initramfs-tools/conf.d"
cat > etc/initramfs-tools/conf.d/casperize.conf <<EOF
export CASPER_GENERATE_UUID=1
EOF
cat <<EOF > /etc/initramfs-tools/conf.d/default-layer.conf
LAYERFS_PATH=filesystem.squashfs
EOF
update-initramfs -c -v -k all

apt-get autoremove -y --purge
apt-get clean