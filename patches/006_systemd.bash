# Install casper so that the initramfs is updated accordingly, will later uninstall through chroot after copying the
#	INITRD and VMLINUZ files from the chroot.
#	THIS BY NATURE REMOVES DRACUT BECAUSE IT DEPENDS ON INITRAMFS-TOOLS
install_packages casper
install_packages cryptsetup cryptsetup-bin cryptsetup-initramfs initramfs-tools
# ~c matches all removed packages with remaining configuration files
apt-get autoremove -y --purge && apt-get purge -y '~c' # dracut is removed but isn't cleaned up, so we do that instead of manually removing it.

export CASPER_GENERATE_UUID=1
export LAYERFS_PATH=filesystem.squashfs
mkdir -p "etc/initramfs-tools/conf.d"
cat > etc/initramfs-tools/conf.d/casperize.conf <<EOF
export CASPER_GENERATE_UUID=1
EOF
cat <<EOF > /etc/initramfs-tools/conf.d/default-layer.conf
LAYERFS_PATH=filesystem.squashfs
EOF
update-initramfs -c -k all

apt-get autoremove -y --purge
apt-get clean