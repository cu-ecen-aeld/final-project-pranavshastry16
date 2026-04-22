#!/bin/sh

. /usr/bin/device_helpers.sh

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html><head><meta charset="UTF-8"><title>Devices Summary</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; margin-bottom: 28px; }
th, td { border:1px solid #ccc; padding:8px; text-align:left; }
th { background:#f0f0f0; }
</style></head><body>
<h1>Devices Summary</h1>
HTML

print_header() {
    echo "<table><tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th></tr>"
}

ONLINE_COUNT=0
OFFLINE_COUNT=0

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if is_online_mac "$mac"; then
            ONLINE_COUNT=$((ONLINE_COUNT + 1))
        else
            OFFLINE_COUNT=$((OFFLINE_COUNT + 1))
        fi
    done < "$LEASE_FILE"
fi

echo "<h2>Online Devices</h2>"
print_header
if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if is_online_mac "$mac"; then
            rem="$(lease_remaining "$expiry")"
            [ "$hostid" = "*" ] && hostid=""
            status="$(status_for_ip_mac "$ip" "$mac")"
            echo "<tr><td>$rem</td><td>$mac</td><td>$ip</td><td>$hostid</td><td>$status</td></tr>"
        fi
    done < "$LEASE_FILE"
fi
echo "</table>"

if [ "$OFFLINE_COUNT" -gt 0 ]; then
    echo "<h2>Offline Devices</h2>"
    print_header
    while read -r expiry mac ip hostid clientid; do
        if ! is_online_mac "$mac"; then
            rem="$(lease_remaining "$expiry")"
            [ "$hostid" = "*" ] && hostid=""
            status="$(status_for_ip_mac "$ip" "$mac")"
            echo "<tr><td>$rem</td><td>$mac</td><td>$ip</td><td>$hostid</td><td>$status</td></tr>"
        fi
    done < "$LEASE_FILE"
    echo "</table>"
fi

echo "</body></html>"
