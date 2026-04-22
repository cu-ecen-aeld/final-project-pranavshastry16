#!/bin/sh

. /usr/bin/device_helpers.sh

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
h1, h2 { margin-top: 0; }
table { border-collapse: collapse; width: 100%; margin-bottom: 28px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
code { background: #f7f7f7; padding: 2px 4px; }
.btn-yellow { padding: 6px 12px; border: none; border-radius: 5px; background: #facc15; color: black; cursor: pointer; }
.btn-blue { display: inline-block; background: #2563eb; color: white; padding: 6px 10px; border-radius: 5px; text-decoration: none; }
.small { color: #555; }
</style>
</head>
<body>
<h1>Unauthenticated Devices</h1>
HTML

print_header() {
    echo "<table><tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th><th>Advanced Control</th></tr>"
}

print_row() {
    expiry="$1"; mac="$2"; ip="$3"; hostid="$4"
    rem="$(lease_remaining "$expiry")"
    [ "$hostid" = "*" ] && hostid=""
    status="$(status_for_ip_mac "$ip" "$mac")"
    echo "<tr>"
    echo "<td>$rem</td>"
    echo "<td><code>$mac</code></td>"
    echo "<td><code>$ip</code></td>"
    echo "<td>$hostid</td>"
    echo "<td class=\"small\">$status</td>"
    echo "<td><form action=\"/cgi-bin/allow.sh\" method=\"get\"><input type=\"hidden\" name=\"ip\" value=\"$ip\"><button class=\"btn-yellow\" type=\"submit\">Allow Access</button></form></td>"
    echo "<td><a class=\"btn-blue\" href=\"/cgi-bin/device_control.sh?ip=$ip\">Advanced Control</a></td>"
    echo "</tr>"
}

OFFLINE_COUNT=0

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if ! in_file "$ip" "$AUTH_FILE" && ! is_online_mac "$mac"; then
            OFFLINE_COUNT=$((OFFLINE_COUNT + 1))
        fi
    done < "$LEASE_FILE"
fi

echo "<h2>Online Unauthenticated Devices</h2>"
print_header
if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if ! in_file "$ip" "$AUTH_FILE" && is_online_mac "$mac"; then
            print_row "$expiry" "$mac" "$ip" "$hostid"
        fi
    done < "$LEASE_FILE"
fi
echo "</table>"

if [ "$OFFLINE_COUNT" -gt 0 ]; then
    echo "<h2>Offline Unauthenticated Devices</h2>"
    print_header
    while read -r expiry mac ip hostid clientid; do
        if ! in_file "$ip" "$AUTH_FILE" && ! is_online_mac "$mac"; then
            print_row "$expiry" "$mac" "$ip" "$hostid"
        fi
    done < "$LEASE_FILE"
    echo "</table>"
fi

echo "</body></html>"
