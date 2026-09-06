#!/bin/bash
set -exuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y \
	cpio \
	debootstrap \
	dosfstools \
	grub-common \
	grub-efi-amd64-bin \
	grub-pc-bin \
	initramfs-tools-core \
	mtools \
	snapd \
	squashfs-tools \
	syslinux-utils \
	tree \
	ubuntu-keyring \
	xorriso

generate_chroot_manifest_full() {
	local debian_pkgs=$(
		chroot "$1" dpkg-query \
			-W --showformat='${Package}	${Version}\n' | sort
	)
	local snap_pkgs=$(
		# shellcheck disable=SC2016
		chroot "$1" awk -F': *' '
  $1 ~ /name/    { name = $2 }
  $1 ~ /channel/ { channel = $2 }
  $1 ~ /file/    { 
    split($2, parts, "[._]"); 
    rev = parts[length(parts)-1]; 
    print "snap:" name "\t" channel "\t" rev 
  }
' /var/lib/snapd/seed/seed.yaml | sort
	)

	echo -e "$debian_pkgs\n$snap_pkgs"
}

setup_chroot() {
	# Mount host directories inside chroot
	mount --bind /dev "$1/dev"
	mount --bind /dev/pts "$1/dev/pts"
	mount -t proc /proc "$1/proc"
	mount -t sysfs /sys "$1/sys"
	mount --bind /run "$1/run"
	mount --rbind /sys/kernel/security "$1/sys/kernel/security" # For snap-preseed

	# Place host resolv.conf for network access
	rm -f "$1/etc/resolv.conf"
	cp -L /etc/resolv.conf "$1/etc/resolv.conf"
}

wrapup_chroot() {
	# Restore original resolv.conf
	rm -f "$1/etc/resolv.conf"
	chroot "$1" /bin/bash -xlc "ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf"

	umount --lazy "$1/sys/kernel/security" --recursive
	umount --lazy "$1/run"
	umount --lazy "$1/sys"
	umount --lazy "$1/proc"
	umount --lazy "$1/dev/pts"
	umount --lazy "$1/dev"
}

# This structure is deduced from livecd-rootfs's source code, but no sufficient documentation is provided on how casper
#	uses these configurations.
initramfstools_casper_gen="export CASPER_GENERATE_UUID=1
export LAYERFS_PATH=filesystem.live.squashfs
mkdir -p \"etc/initramfs-tools/conf.d\"
cat > etc/initramfs-tools/conf.d/casperize.conf <<EOF
export CASPER_GENERATE_UUID=1
EOF
cat <<EOF > /etc/initramfs-tools/conf.d/default-layer.conf
LAYERFS_PATH=filesystem.live.squashfs
EOF
update-initramfs -c -k all"

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

setup_chroot "$CHROOT_DIR"

#^ Copy setup script to chroot, run it, and then remove it
cp /workspace/dist/${SH_NAME} "$CHROOT_DIR/opt/"
chmod +x "$CHROOT_DIR/opt/${SH_NAME}"
chroot "$CHROOT_DIR" /bin/bash -xlc "/opt/${SH_NAME}"
rm -f "$CHROOT_DIR/opt/${SH_NAME}"

#^ Snaps
mkdir -p "$CHROOT_DIR/var/lib/snapd/seed/"
cp -r /workspace/tooling/seed/* "$CHROOT_DIR/var/lib/snapd/seed/"

/usr/lib/snapd/snap-preseed "$CHROOT_DIR"
chroot "$CHROOT_DIR" /bin/bash -xlc "dracut --force" # Update InitRAMFS since Snap seeding adds files to /etc/
tree "$CHROOT_DIR/var/lib/snapd/"

wrapup_chroot "$CHROOT_DIR"

#^ Live Layer

MERGED_CHROOT_DIR="/workspace/merged"
LIVE_OVERLAY_DIR="/workspace/live-upper"
mkdir -p "$LIVE_OVERLAY_DIR" /workspace/live-work "$MERGED_CHROOT_DIR"
mount -t overlay overlay \
	-o lowerdir="$CHROOT_DIR",upperdir="$LIVE_OVERLAY_DIR",workdir=/workspace/live-work \
	"$MERGED_CHROOT_DIR"

setup_chroot "$MERGED_CHROOT_DIR"

# This is a well-known workaround for Chromium browsers showing permission errors:
#		[6611:6611:0804/130457.772606:FATAL:sandbox/linux/services/credentials.cc:131] Check failed: . : Permission denied (13)
#		[0804/130458.000648:ERROR:third_party/crashpad/crashpad/util/file/file_io_posix.cc:145] open /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: No such file or directory (2)
#		[0804/130458.000853:ERROR:third_party/crashpad/crashpad/util/file/file_io_posix.cc:145] open /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: No such file or directory (2)
#		/usr/bin/brave-browser: line 30: 6611 Trace/breakpoint trap	(core dumped) "$HERE/brave" "$@"
#
# For some reason, Brave only worked after installing the system, but not inside the live environment. We previously couldn't do anything about this; however, now
# that we properly use multi-layered filesystems, we can do the unsecure workaround in the live layer, and keep everything intact for the base system image.
#
#? NOTE: After initially thinking of this solution way long ago when it first appeared, I had considered it a bad idea security-wise; however, I did not re-think through
#? 	it after we switched to multi-layered filesystems, and only now did an LLM (yes, just hang on for a second) re-surface this idea to me.
#!	BIG HOWEVER, I *did* do my due diligence, and looked through the live layer on an official Ubuntu ISO, only to be surprised that /etc/sysctl.d/20-apparmor.conf DID
#!	exist there, with one more rule than what I'd originally planned. I decided to therefore just copy that file, since it seems to be a needed workaround for browsers
#!	in general, not just Chromium (Ubuntu uses Firefox).
mkdir -p "$MERGED_CHROOT_DIR/etc/sysctl.d"
cat > "$MERGED_CHROOT_DIR/etc/sysctl.d/20-apparmor.conf" <<'EOF'
# AppArmor restrictions of unprivileged user namespaces

# Disables AppArmor user namespace restrictions on the live ISO.
kernel.apparmor_restrict_unprivileged_userns = 0
kernel.apparmor_restrict_unprivileged_unconfined = 1

EOF

# TODO: Fix user needing to enter a password (or leaving it blank) when launching Brave

# InitRAMFS changes
chroot "$MERGED_CHROOT_DIR" /bin/bash -xlc "apt-get install -y casper
apt-get install -y cryptsetup cryptsetup-bin cryptsetup-initramfs initramfs-tools
# ~c matches all removed packages with remaining configuration files
apt-get autoremove -y --purge && apt-get purge -y '~c' # dracut is removed but isn't cleaned up, so we do that instead of manually removing it.

$initramfstools_casper_gen"

# Additional packages (https://static-reports.ubuntu.com/seeds/ubuntu.resolute/live contains some, but not all, of these, so our reference is
#	`casper/minimal.standard.live.manifest` on official ISOs)
chroot "$MERGED_CHROOT_DIR" /bin/bash -xlc "apt-get install -y \
adcli \
btrfs-progs \
cifs-utils \
dmeventd \
efibootmgr \
finalrd \
gawk \
gparted \
grub-efi-amd64-bin \
grub-efi-amd64-signed \
grub-efi-amd64-unsigned \
gtk-im-libthai \
ibus-hangul \
ibus-mozc \
ibus-unikey \
jfsutils \
keyutils \
localechooser-data \
lvm2 \
mdadm \
realmd \
shim-signed \
thin-provisioning-tools \
user-setup \
xfsprogs \
zfs-zed

apt-get autoremove -y --purge
apt-get clean"

#^ Ubuntu Desktop Bootstrap
cp -r /workspace/tooling/seed-live/* "$MERGED_CHROOT_DIR/var/lib/snapd/seed/"

/usr/lib/snapd/snap-preseed --reset "$MERGED_CHROOT_DIR"
/usr/lib/snapd/snap-preseed "$MERGED_CHROOT_DIR"
chroot "$MERGED_CHROOT_DIR" /bin/bash -xlc "$initramfstools_casper_gen" # Update InitRAMFS since Snap seeding adds files to /etc/
tree "$MERGED_CHROOT_DIR/var/lib/snapd/"

# Kernel and INITRD

export ISO_DIR="/workspace/utile-iso"
mkdir -p "$ISO_DIR/casper"
VMLINUZ=$(ls -1 "$MERGED_CHROOT_DIR/boot/vmlinuz-"* | tail -n 1)
INITRD=$(ls -1 "$MERGED_CHROOT_DIR/boot/initrd.img-"* | tail -n 1)
cp "$VMLINUZ" "$ISO_DIR/casper/vmlinuz"
cp "$INITRD" "$ISO_DIR/casper/initrd"

wrapup_chroot "$MERGED_CHROOT_DIR"

# Make squashfs

mksquashfs "$CHROOT_DIR" "$ISO_DIR/casper/filesystem.squashfs" -comp xz -noappend
mksquashfs "$LIVE_OVERLAY_DIR" "$ISO_DIR/casper/filesystem.live.squashfs" -comp xz -noappend

# Casper metadata

FILESYSTEM_SIZE=$(du -sx --block-size=1 "$CHROOT_DIR" | cut -f1)
printf '%s' "$FILESYSTEM_SIZE" \
	> "$ISO_DIR/casper/filesystem.size"
LIVE_FILESYSTEM_SIZE=$(du -sx --block-size=1 "$MERGED_CHROOT_DIR" | cut -f1)
printf '%s' "$LIVE_FILESYSTEM_SIZE" \
	> "$ISO_DIR/casper/filesystem.live.size"

generate_chroot_manifest_full "$CHROOT_DIR" \
	> "$ISO_DIR/casper/filesystem.manifest.full"
generate_chroot_manifest_full "$MERGED_CHROOT_DIR" \
	> "$ISO_DIR/casper/filesystem.live.manifest.full"

chroot "$CHROOT_DIR" echo \
"--- $ISO_DIR/casper/.manifest.full	1970-01-01 00:00:00.000000000 +0000
+++ $ISO_DIR/casper/filesystem.manifest.full	1970-01-01 00:00:00.000000000 +0000
" > "$ISO_DIR/casper/filesystem.manifest"

# Prepend a + to each line
sed 's/^/+/' "$ISO_DIR/casper/filesystem.manifest.full" \
	>> "$ISO_DIR/casper/filesystem.manifest"

diff -U 0 "$ISO_DIR/casper/filesystem.manifest.full" "$ISO_DIR/casper/filesystem.live.manifest.full" | grep -v "^@@" \
	> "$ISO_DIR/casper/filesystem.live.manifest" || true

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
  size: $FILESYSTEM_SIZE
  type: fsimage-layered
  variant: desktop
  variations:
    standard:
      path: filesystem.squashfs
      size: $(stat -c %s "$ISO_DIR/casper/filesystem.squashfs")
version: 2" > "$ISO_DIR/casper/install-sources.yaml"

# .disk/ and boot/
if [ -d /workspace/tooling/iso_overlay ]; then
	cp -r /workspace/tooling/iso_overlay/. "$ISO_DIR"
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

#^ ISO Debian Repository
# TODO: big stuff right here, should leave it alone until tested. This could probably end up making a copy of the filesystem we already have since we don't check if
# TODO: 	the dependencies are already available
# echo "Creating cdrom repository..."
# # https://static-reports.ubuntu.com/seeds/ubuntu.resolute/ship-live
# cat > /workspace/packages.txt <<'EOF'
# sl-modem-daemon
# intel-microcode
# amd64-microcode
# setserial
# b43-fwcutter
# broadcom-sta-dkms
# openssh-server
# wpasupplicant
# bcache-tools
# btrfs-progs
# cryptsetup
# e2fsprogs
# jfsutils
# lvm2
# mdadm
# ntfs-3g
# open-iscsi
# reiserfsprogs
# xfsprogs
# zfsutils-linux
# multipath-tools-boot
# grub-efi-amd64
# grub-efi-amd64-signed
# grub-pc
# shim-signed
# efibootmgr
# mdadm
# zfs-dracut
# sssd
# realmd
# /^oem-.+-meta$/
# /^linux-modules-iwlwifi-generic-hwe-26.04$/
# /^linux-modules-ipu6-generic-hwe-26.04$/
# /^linux-modules-ipu7-generic-hwe-26.04$/
# /^nvidia-driver-580$/
# /^nvidia-driver-595$/
# /^linux-modules-nvidia-580-generic-hwe-26.04$/
# /^linux-modules-nvidia-595-generic-hwe-26.04$/
# nvidia-prime
# EOF
# mapfile -t PACKAGES < <(grep -vE '^\s*#|^\s*$' /workspace/packages.txt)

# add-apt-repository restricted -y
# apt-get update && apt-get install -y apt-rdepends

# POOL_DIR="$ISO_DIR/pool"
# components=(main restricted)

# mkdir -p "$POOL_DIR"

# mapfile -t MATCHED_REGEX < <(
# 	for pkg in "${PACKAGES[@]}"; do
# 		[[ "$pkg" =~ ^[[:space:]]*# ]] && continue # Comments

# 		if [[ "$pkg" =~ ^/(.*)/$ ]]; then
# 			pattern="${BASH_REMATCH[1]}"
# 			apt-cache pkgnames | grep -E "^${pattern}$"
# 		else
# 			echo "$pkg"
# 		fi
# 	done | sort -u
# )

# mapfile -t FULL_LIST < <(
# 	for pkg in "${MATCHED_REGEX[@]}"; do
# 		apt-rdepends "$pkg" 2>/dev/null | grep -v "^ "
# 	done | sort -u
# )

# for pkg in "${FULL_LIST[@]}"; do
# 	pkg_info=$(apt-cache show "$pkg" 2>/dev/null)

# 	path=$(echo "$pkg_info" | awk '/^Filename:/{print $2; exit}')
# 	component=$(echo "$path" | cut -d'/' -f2)

# 	if [[ "$component" != "main" && "$component" != "restricted" ]]; then # Some NVIDIA drivers come from multiverse, but are still in restricted on the ISOs
#         path="pool/restricted/${path#pool/"$component"/}"
#     fi

# 	dest="$ISO_DIR/$(dirname "$path")"
# 	mkdir -p "$dest"
# 	( cd "$dest" && apt-get download "$pkg" 2>/dev/null ) || echo "Failed to download $pkg" >&2
# done

# for component in "${components[@]}"; do
# 	component_dir="$POOL_DIR/$component"

# 	binary_dir="$ISO_DIR/dists/resolute/$component/binary-amd64"
# 	mkdir -p "$binary_dir"

# 	apt-ftparchive packages "$component_dir" > "$binary_dir/Packages"
# 	gzip -k -f "$binary_dir/Packages"
# done

# cat > "$ISO_DIR/dists/resolute/Release" <<EOF
# Origin: Ubuntu
# Label: Ubuntu
# Suite: resolute
# Version: 26.04
# Codename: resolute
# Date: $(date -u +"%a, %d %b %Y %H:%M:%S UTC")
# Architectures: amd64
# Components: main restricted
# Description: Ubuntu Resolute 26.04
# EOF

# apt-ftparchive --no-md5 --no-sha1 release . >> "$ISO_DIR/dists/resolute/Release"
# ln -sf "$ISO_DIR/dists/resolute" "$ISO_DIR/dists/stable" && ln -sf "$ISO_DIR/dists/resolute" "$ISO_DIR/dists/unstable"

# echo "Finished creating cdrom repository"
# tree "$ISO_DIR/pool" "$ISO_DIR/dists"

#^ Packing
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
