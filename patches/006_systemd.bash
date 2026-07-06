# Install casper so that the initramfs is updated accordingly, will later uninstall through chroot after copying the
#	INITRD and VMLINUZ files from the chroot. This could fix the problem with SystemD's
#	`[FAILED] Failed to start initrd-switch-root.service - Switch Root.` error. Not that I did any research on it,
#	but I found https://askubuntu.com/questions/1244623/make-a-custom-ubuntu-20-04-usb-boot-thumb-drive
install_packages casper

apt-get autoremove -y --purge
apt-get clean