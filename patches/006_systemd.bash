# Install casper so that the initramfs is updated accordingly, will later uninstall through chroot after copying the
#	INITRD and VMLINUZ files from the chroot. This could fix the problem with SystemD's
#	`[FAILED] Failed to start initrd-switch-root.service - Switch Root.` error. Not that I did any research on it,
#	but I found 
#	THIS BY NATURE REMOVES DRACUT BECAUSE IT DEPENDS ON INITRAMFS-TOOLS
install_packages casper

apt-get autoremove -y --purge
apt-get clean