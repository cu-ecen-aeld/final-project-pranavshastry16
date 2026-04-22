#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
AUTH_FILE="/tmp/authorized_clients"
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
    if in_file "$ip" "$BLOCKED_FILE"; then
        echo "Permanently Blocked"
    else
        echo "Unauthenticated"
    fi
}

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Unauthenticated Devices</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
h1 { margin-top: 0; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
code { background: #f7f7f7; padding: 2px 4px; }
.btn-yellow { padding: 6px 12px; border: none; border-radius: 5px; background: #facc15; color: black; cursor: pointer; }
.small { color: #555; }
.btn-blue { display: inline-block; background: #2563eb; color: white; padding: 6px 10px; border-radius: 5px; text-decoration: none; }
</style>
</head>
<body>
<h1>Unauthenticated Devices</h1>
<table>
<tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th><th>Advanced Control</th></tr>
HTML

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if ! in_file "$ip" "$AUTH_FILE"; then
            [ "$hostid" = "*" ] && hostid=""
            rem="$(lease_remaining "$expiry")"
            status="$(status_for_ip "$ip")"
            echo "<tr>"
            echo "<td>$rem</td>"
            echo "<td><code>$mac</code></td>"
            echo "<td><code>$ip</code></td>"
            echo "<td>$hostid</td>"
            echo "<td class=\"small\">$status</td>"
            echo "<td>"
            echo "<form action=\"/cgi-bin/allow.sh\" method=\"get\">"
            echo "<input type=\"hidden\" name=\"ip\" value=\"$ip\">"
            echo "<button class=\"btn-yellow\" type=\"submit\">Allow Access</button>"
            echo "</form>"
            echo "</td>"
            echo "<td><a class=\"btn-blue\" href=\"/cgi-bin/device_control.sh?ip=$ip\">Advanced Control</a></td>"
            echo "</tr>"
        fi
    done < "$LEASE_FILE"
fi

echo "</table></body></html>"
