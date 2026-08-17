# The Snap daemon isn't running in chroot, but it is running on existing systems
if [ "$ENV_MODE" == "POST" ]; then
	snap remove --purge firefox || true
	snap remove --purge thunderbird || true
fi

# We need to be as harsh as possible here, one issue of snaps is that they're hard to control since they require the snapd daemon to be running before we
#	can remove them easily. This is a remnant of when our repository used to only download an official Ubuntu ISO and modify it, and therefore we had no control
#	over built-in snaps and had to manually delete these files (which still didn't work, and after successfully seeding our own snaps, I think I know why this
#	had no chance of working. Snap seeding is for some reason way more complex than just having the right files in the right place).
#	TODO: I'm unsure if we should remove the `find` commands from here just yet...
apt-get purge -y firefox thunderbird || true
apt-mark hold firefox thunderbird

find /var/snap -name "*firefox*" -delete
find /var/snap -name "*thunderbird*" -delete

find /var/lib/snapd -name "*firefox*" -delete
find /var/lib/snapd -name "*thunderbird*" -delete

find /usr/share -name "*firefox*" -delete
find /usr/share -name "*thunderbird*" -delete

find /var/cache/apparmor -name "*firefox*" -delete
find /var/cache/apparmor -name "*thunderbird*" -delete

sudo rm -rf /var/cache/snapd/

#* echo "Remaining Firefox entries:"
#* find /usr /var -name "*firefox*"