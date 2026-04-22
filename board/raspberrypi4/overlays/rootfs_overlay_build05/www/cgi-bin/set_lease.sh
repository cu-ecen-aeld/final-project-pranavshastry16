#!/bin/sh

QUERY="$QUERY_STRING"
IP="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^ip=//p' | head -n1 | sed 's/%2E/./g')"
HOURS="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^hours=//p' | head -n1)"

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
TMP="/tmp/dnsmasq.leases.tmp"

NOW="$(date +%s)"
NEW_EXPIRY=$((NOW + HOURS * 3600))

awk -v ip="$IP" -v newexp="$NEW_EXPIRY" '
BEGIN { OFS=" " }
$3 == ip { $1 = newexp }
{ print $1, $2, $3, $4, $5 }' "$LEASE_FILE" > "$TMP"

mv "$TMP" "$LEASE_FILE"

echo "Status: 302 Found"
echo "Location: /cgi-bin/device_control.sh?ip=$IP"
echo ""
