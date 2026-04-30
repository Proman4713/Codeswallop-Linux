if [ "$ENV_MODE" == "POST" ]; then
	snap remove --purge firefox || true
	snap remove --purge thunderbird || true
fi

rm -rf /var/lib/snapd/seed/snaps/firefox_*
rm -rf /var/lib/snapd/seed/snaps/thunderbird_*

if [ -f /var/lib/snapd/seed/seed.yaml ]; then
	sed -i '/firefox/d' /var/lib/snapd/seed/seed.yaml
	sed -i '/thunderbird/d' /var/lib/snapd/seed/seed.yaml
fi