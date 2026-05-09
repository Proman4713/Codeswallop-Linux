if [ "$ENV_MODE" == "POST" ]; then
	snap remove --purge firefox || true
	snap remove --purge thunderbird || true
fi

# We need to be as harsh as possible here, one issue of snaps is that they're hard to control since they require the snapd daemon to be running before we
#	can remove them easily.
apt-mark hold firefox thunderbird
apt-get purge -y firefox thunderbird || true

rm -rf /var/lib/snapd/seed/snaps/*firefox*
rm -rf /var/lib/snapd/seed/snaps/*thunderbird*

rm -rf /var/lib/snapd/snaps/*firefox*
rm -rf /var/lib/snapd/snaps/*thunderbird*

rm -rf /var/snap/*firefox*
rm -rf /var/snap/*thunderbird*

if [ -f /var/lib/snapd/seed/seed.yaml ]; then
	sed -i '/firefox/d' /var/lib/snapd/seed/seed.yaml
	sed -i '/thunderbird/d' /var/lib/snapd/seed/seed.yaml
fi