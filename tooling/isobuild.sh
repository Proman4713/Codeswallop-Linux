#!/bin/bash
set -exuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y \
	debootstrap \
	ubuntu-keyring \
	squashfs-tools \
	xorriso \
	dosfstools \
	mtools \
	syslinux-utils \
	grub-common \
	grub-pc-bin \
	grub-efi-amd64-bin \
	cpio \
	initramfs-tools-core

export CHROOT_DIR="/workspace/chroot"
mkdir -p "$CHROOT_DIR"
debootstrap \
	--arch=amd64 \
	--components=main,restricted,universe,multiverse \
	--keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg \
	--verbose \
	resolute \
	"$CHROOT_DIR" \
	http://archive.ubuntu.com/ubuntu

# Mount host directories inside chroot
mount --bind /dev "$CHROOT_DIR/dev"
mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
mount -t proc /proc "$CHROOT_DIR/proc"
mount -t sysfs /sys "$CHROOT_DIR/sys"
mount --bind /run "$CHROOT_DIR/run"

# Place host resolv.conf for network access
rm -f "$CHROOT_DIR/etc/resolv.conf"
cp -L /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"

# Copy setup script to chroot, run it, and then remove it
cp /workspace/dist/${SH_NAME} "$CHROOT_DIR/opt/"
chmod +x "$CHROOT_DIR/opt/${SH_NAME}"
chroot "$CHROOT_DIR" /bin/bash -xlc "/opt/${SH_NAME}"
rm -f "$CHROOT_DIR/opt/${SH_NAME}"

# Kernel and INITRD

export ISO_DIR="/workspace/custom-iso"
mkdir -p "$ISO_DIR/casper"
VMLINUZ=$(ls -1 "$CHROOT_DIR/boot/vmlinuz-"* | tail -n 1)
INITRD=$(ls -1 "$CHROOT_DIR/boot/initrd.img-"* | tail -n 1)
cp "$VMLINUZ" "$ISO_DIR/casper/vmlinuz"
cp "$INITRD" "$ISO_DIR/casper/initrd"

# Remove casper from inside the chroot after copying the casper-enabled initrd out of it and restore dracut
chroot "$CHROOT_DIR" /bin/bash -xlc "export DEBIAN_FRONTEND=noninteractive && apt-get purge -y casper && apt-get install -y dracut && apt-get purge -y initramfs-tools && apt-get autoremove -y --purge && apt-get clean && dracut --force"

# Restore original resolv.conf
rm -f "$CHROOT_DIR/etc/resolv.conf"
chroot "$CHROOT_DIR" /bin/bash -xlc "ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf"

# Snap seed
mkdir -p "$CHROOT_DIR/var/lib/snapd/seed/"
cp -r /workspace/tooling/seed/* "$CHROOT_DIR/var/lib/snapd/seed/"

umount --lazy "$CHROOT_DIR/run"
umount --lazy "$CHROOT_DIR/sys"
umount --lazy "$CHROOT_DIR/proc"
umount --lazy "$CHROOT_DIR/dev/pts"
umount --lazy "$CHROOT_DIR/dev"

# Make squashfs
mksquashfs "$CHROOT_DIR" "$ISO_DIR/casper/filesystem.squashfs" -comp xz -noappend -e boot

# Casper metadata

FILESYSTEM_SIZE=$(du -sx --block-size=1 "$CHROOT_DIR" | cut -f1)
printf '%s' "$FILESYSTEM_SIZE" \
	> "$ISO_DIR/casper/filesystem.size"
chroot "$CHROOT_DIR" dpkg-query \
	-W --showformat='${Package}	${Version}\n' | sort \
	> "$ISO_DIR/casper/filesystem.manifest"
echo "kernel:
  default: linux-generic-hwe-24.04
sources:
- default: true
  description:
    en: The full Utile OS experience.
  id: ubuntu-desktop-minimal
  locale_support: langpack
  name:
    en: Standard
  path: filesystem.squashfs
  preinstalled_langs:
  - en
  - ''
  size: $FILESYSTEM_SIZE
  type: fsimage
  variant: desktop
  variations:
    standard:
      path: filesystem.squashfs
      size: $(stat -c %s "$ISO_DIR/casper/filesystem.squashfs")
version: 2" > "$ISO_DIR/casper/install-sources.yaml"

# .disk/ and iso_overlay/
cp -r /workspace/tooling/.disk "$ISO_DIR"
if [ -d /workspace/tooling/iso_overlay ]; then
	cp -r /workspace/tooling/iso_overlay/* "$ISO_DIR"
fi

#* From this point onward, a lot of stuff is inspired by the livecd-rootfs package

#^ Parity with official ISOs
ln -s . "$ISO_DIR/ubuntu"
touch "$ISO_DIR/.disk/base_installable"
echo "full_cd/single" > "$ISO_DIR/.disk/cd_type"

#^ .disk/casper-uuid-*
INITRD_DIR="/tmp/extracted-initrd"
mkdir -p "$INITRD_DIR"
unmkinitramfs "$ISO_DIR/casper/initrd" "$INITRD_DIR"
UUID_CONF=$(find "$INITRD_DIR" -type f -path "*/conf/uuid.conf" -o -path "conf/uuid.conf" | head -n 1)
if [ -f "$UUID_CONF" ] && [ -n "$UUID_CONF" ]; then
	echo "found $UUID_CONF"
	mv "$UUID_CONF" "$ISO_DIR/.disk/casper-uuid-generic"
else
	echo "uuid.conf not found"
	exit 1
fi

rm -rf "$INITRD_DIR"

#^ Official GRUB images
	OFFICIAL_IMAGES="/tmp/extracted-uefi-images"
	mkdir -p "$OFFICIAL_IMAGES"
	apt-get download shim-signed grub-efi-amd64-signed grub-pc-bin grub-efi-amd64-bin grub2-common
	for deb in *.deb; do dpkg -x "$deb" "$OFFICIAL_IMAGES"; done

	#? boot/grub/
	mkdir -p "$ISO_DIR/boot/grub/x86_64-efi/"
	find "$OFFICIAL_IMAGES/usr/lib/grub/x86_64-efi/" -type f \( -name "*.lst" -o -name "*.mod" \) -print0 | xargs -0 cp -t "$ISO_DIR/boot/grub/x86_64-efi"
	mkdir -p "$ISO_DIR/boot/grub/i386-pc/"
	cp -r "$OFFICIAL_IMAGES/usr/lib/grub/i386-pc/." "$ISO_DIR/boot/grub/i386-pc/"

	#? boot/grub/fonts
	mkdir -p "$ISO_DIR/boot/grub/fonts"
	# grub-common is installed on the host, no need to download it
	cp /usr/share/grub/unicode.pf2 "$ISO_DIR/boot/grub/fonts" || true

	#? EFI/boot
	mkdir -p "$ISO_DIR/EFI/boot"
	cp "$OFFICIAL_IMAGES/usr/lib/shim/shimx64.efi.signed.latest" "$ISO_DIR/EFI/boot/bootx64.efi"
	cp "$OFFICIAL_IMAGES/usr/lib/shim/mmx64.efi" "$ISO_DIR/EFI/boot/mmx64.efi"
	cp "$OFFICIAL_IMAGES/usr/lib/grub/x86_64-efi-signed/gcdx64.efi.signed" "$ISO_DIR/EFI/boot/grubx64.efi"

# Calculate how much space is needed for EFI System Partition + 1 KiB headroom
EFI_SIZE=$(($(du -s --apparent-size --block-size=1024 "$ISO_DIR/EFI/" | cut -f1) + 1024))
# Create a FAT filesystem there (livecd-rootfs prefers mkfs.msdos, they're identical, so who cares)
mkfs.msdos -n ESP -C /tmp/efi.img "$EFI_SIZE"

# Copy the official UEFI images to the EFI/ directory inside this image (-s recursive)
mcopy -s -i /tmp/efi.img "$ISO_DIR/EFI/" ::/.

# md5sum
(cd "$ISO_DIR" && find . -type f ! -name "md5sum.txt" ! -name "eltorito.img" ! -name "grub.cfg" -print0 | sort -z | xargs -0 md5sum > "$ISO_DIR/md5sum.txt")

xorriso -as mkisofs \
	-iso-level 3 \
	-J -joliet-long \
	-full-iso9660-filenames \
	-volid "Utile OS 26 amd64" \
	--mbr-force-bootable \
	-b boot/grub/i386-pc/eltorito.img \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		--grub2-boot-info \
		--grub2-mbr "$OFFICIAL_IMAGES/usr/lib/grub/i386-pc/boot_hybrid.img" \
	-eltorito-alt-boot \
		-e --interval:appended_partition_2:all:: \
		-no-emul-boot \
		-partition_offset 16 \
	-append_partition 2 0xef /tmp/efi.img \
	-appended_part_as_gpt \
	-c boot.catalog \
	-o /workspace/${ISO_NAME}-amd64.iso \
	"$ISO_DIR"
				
echo "ISO created: $(ls -lh /workspace/${ISO_NAME}-amd64.iso)"