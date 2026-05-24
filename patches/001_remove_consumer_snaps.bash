if [ "$ENV_MODE" == "POST" ]; then
	snap remove --purge firefox || true
	snap remove --purge thunderbird || true
fi

# We need to be as harsh as possible here, one issue of snaps is that they're hard to control since they require the snapd daemon to be running before we
#	can remove them easily.
apt-get purge -y firefox thunderbird || true
apt-mark hold firefox thunderbird

rm -rf /var/lib/snapd/seed/snaps/*firefox*
rm -rf /var/lib/snapd/seed/snaps/*thunderbird*

rm -rf /var/lib/snapd/snaps/*firefox*
rm -rf /var/lib/snapd/snaps/*thunderbird*

rm -rf /var/snap/*firefox*
rm -rf /var/snap/*thunderbird*

rm -rf /usr/share/applications/*firefox*
rm -rf /usr/share/applications/*thunderbird*

rm -rf /var/lib/snapd/desktop/applications/*firefox*
rm -rf /var/lib/snapd/desktop/applications/*thunderbird*

# Leftovers
find /var/lib/snapd -name "*firefox*" -delete
find /var/lib/snapd -name "*thunderbird*" -delete

find /usr/share/icons -name "*firefox*" -delete
find /usr/share/icons -name "*thunderbird*" -delete

find /usr/share/bash-completion -name "*firefox*" -delete
find /usr/share/bash-completion -name "*thunderbird*" -delete

find /var/cache/apparmor -name "*firefox*" -delete
find /var/cache/apparmor -name "*thunderbird*" -delete

sudo rm -rf /var/cache/snapd/

#* echo "Remaining Firefox entries:"
#* find /usr /var -name "*firefox*"