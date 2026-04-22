#!/bin/sh
QUERY="$QUERY_STRING"
SSID="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^ssid=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g')"
PASS="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^pass=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g')"
SEC="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^security=//p' | head -n1)"

cat > /etc/gateway/wireless.conf <<CFG
SSID="${SSID}"
SECURITY="${SEC}"
PASSPHRASE="${PASS}"
CFG

if [ "$SEC" = "open" ]; then
cat > /etc/hostapd.conf <<CFG
interface=wlan0
driver=nl80211
ssid=${SSID}
hw_mode=g
channel=6
auth_algs=1
ignore_broadcast_ssid=0
CFG
elif [ "$SEC" = "wpa3" ]; then
cat > /etc/hostapd.conf <<CFG
interface=wlan0
driver=nl80211
ssid=${SSID}
hw_mode=g
channel=6
wpa=2
wpa_key_mgmt=SAE
rsn_pairwise=CCMP
ieee80211w=2
sae_password=${PASS}
CFG
else
cat > /etc/hostapd.conf <<CFG
interface=wlan0
driver=nl80211
ssid=${SSID}
hw_mode=g
channel=6
wpa=2
wpa_passphrase=${PASS}
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
CFG
fi

echo "Content-Type: text/html"
echo ""
echo "<html><body style=\"font-family:Arial;margin:24px;\"><h1>System is restarting...</h1><p>May take up to 1 minute.</p></body></html>"
(sync; sleep 3; reboot) >/dev/null 2>&1 &
