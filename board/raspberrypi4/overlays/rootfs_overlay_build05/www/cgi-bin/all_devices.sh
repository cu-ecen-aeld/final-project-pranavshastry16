#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
AUTH_FILE="/tmp/authorized_clients"
AUTH_PORTAL="/tmp/authenticated_clients"
AUTH_MANUAL="/tmp/manual_allowed_clients"
AUTH_PERM="/tmp/permanent_allowed_clients"
BLOCKED_FILE="/tmp/permanent_blocked_clients"

lease_remaining() {
    expiry="$1"
    now="$(date +%s 2>/dev/null)"
    [ -n "$now" ] || now=0
    rem=$((expiry - now))
    [ "$rem" -lt 0 ] && rem=0
    hrs=$((rem / 3600))
    mins=$(((rem % 3600) / 60))
    secs=$((rem % 60))
    printf "%02dh %02dm %02ds" "$hrs" "$mins" "$secs"
}

in_file() {
    val="$1"
    file="$2"
    grep -qx "$val" "$file" 2>/dev/null
}

status_for_ip() {
    ip="$1"
    if in_file "$ip" "$AUTH_PERM"; then
        echo "Permanently Allowed"
    elif in_file "$ip" "$AUTH_MANUAL"; then
        echo "Manually Allowed"
    elif in_file "$ip" "$AUTH_PORTAL"; then
        echo "Authenticated"
    elif in_file "$ip" "$BLOCKED_FILE"; then
        echo "Permanently Blocked"
    else
        echo "Unauthenticated"
    fi
}

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html><head><meta charset="UTF-8"><title>All Devices</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; }
th, td { border:1px solid #ccc; padding:8px; text-align:left; }
th { background:#f0f0f0; }
</style></head><body>
<h1>All Devices</h1>
<table>
<tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th></tr>
HTML

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        [ "$hostid" = "*" ] && hostid=""
        rem="$(lease_remaining "$expiry")"
        status="$(status_for_ip "$ip")"
        echo "<tr><td>$rem</td><td>$mac</td><td>$ip</td><td>$hostid</td><td>$status</td></tr>"
    done < "$LEASE_FILE"
fi

echo "</table></body></html>"
