#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
AUTH_FILE="/tmp/authorized_clients"
AUTH_PORTAL="/tmp/authenticated_clients"
AUTH_MANUAL="/tmp/manual_allowed_clients"
AUTH_PERM="/tmp/permanent_allowed_clients"

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
    else
        echo "Connected"
    fi
}

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Authenticated Devices</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
h1 { margin-top: 0; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
code { background: #f7f7f7; padding: 2px 4px; }
.btn-red { padding: 6px 12px; border: none; border-radius: 5px; background: #b91c1c; color: white; cursor: pointer; }
.badge-green { display: inline-block; background: #15803d; color: white; padding: 6px 10px; border-radius: 5px; font-weight: bold; }
.btn-blue { display: inline-block; background: #2563eb; color: white; padding: 6px 10px; border-radius: 5px; text-decoration: none; }
</style>
</head>
<body>
<h1>Authenticated Devices</h1>
<table>
<tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th><th>Advanced Control</th></tr>
HTML

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if in_file "$ip" "$AUTH_FILE"; then
            [ "$hostid" = "*" ] && hostid=""
            rem="$(lease_remaining "$expiry")"
            status="$(status_for_ip "$ip")"
            echo "<tr>"
            echo "<td>$rem</td>"
            echo "<td><code>$mac</code></td>"
            echo "<td><code>$ip</code></td>"
            echo "<td>$hostid</td>"
            echo "<td><span class=\"badge-green\">$status</span></td>"
            echo "<td>"
            echo "<form action=\"/cgi-bin/deauth.sh\" method=\"get\">"
            echo "<input type=\"hidden\" name=\"ip\" value=\"$ip\">"
            echo "<button class=\"btn-red\" type=\"submit\">Remove Access</button>"
            echo "</form>"
            echo "</td>"
            echo "<td><a class=\"btn-blue\" href=\"/cgi-bin/device_control.sh?ip=$ip\">Advanced Control</a></td>"
            echo "</tr>"
        fi
    done < "$LEASE_FILE"
fi

echo "</table></body></html>"
