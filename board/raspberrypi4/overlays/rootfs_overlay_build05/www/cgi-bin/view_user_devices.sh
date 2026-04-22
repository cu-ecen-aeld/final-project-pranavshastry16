#!/bin/sh
USER="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^user=//p' | head -n1 | sed 's/+/ /g')"
MAP_DB="/etc/gateway/device_account_map.db"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"

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

usage_for_ip() {
    ip="$1"
    iptables -L FORWARD -v -n 2>/dev/null | awk -v ip="$ip" '
    $0 ~ ip { bytes += $2 }
    END {
        if (bytes == "" || bytes == 0) print "0 B";
        else if (bytes < 1024) print bytes " B";
        else if (bytes < 1048576) printf "%.1f KB", bytes/1024;
        else printf "%.2f MB", bytes/1048576;
    }'
}

echo "Content-Type: text/html"
echo ""
cat <<HTML
<html>
<head>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; background: white; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
</style>
</head>
<body>
<h1>User Account: $USER</h1>
<table>
<tr><th>IP</th><th>MAC</th><th>Lease Time Left</th><th>Data Usage</th></tr>
HTML

awk -F'|' -v u="$USER" '$3 == u { print $1 "|" $2 }' "$MAP_DB" 2>/dev/null | while IFS='|' read -r ip mac; do
    [ -z "$ip" ] && continue
    lease="$(awk -v ip="$ip" '$3==ip {print $1; exit}' "$LEASE_FILE")"
    [ -n "$lease" ] && left="$(lease_remaining "$lease")" || left="-"
    usage="$(usage_for_ip "$ip")"
    echo "<tr><td>$ip</td><td>$mac</td><td>$left</td><td>$usage</td></tr>"
done

echo "</table></body></html>"
