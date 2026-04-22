#!/bin/sh

. /usr/bin/device_helpers.sh
MAP_DB="/etc/gateway/device_account_map.db"

user_for_mac() {
    mac="$1"
    [ -f "$MAP_DB" ] || return 0
    awk -F'|' -v m="$mac" '$2 == m { print $3; exit }' "$MAP_DB"
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
h1, h2 { margin-top: 0; }
table { border-collapse: collapse; width: 100%; margin-bottom: 28px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
code { background: #f7f7f7; padding: 2px 4px; }
.btn-red { padding: 6px 12px; border: none; border-radius: 5px; background: #b91c1c; color: white; cursor: pointer; }
.btn-blue { display: inline-block; background: #2563eb; color: white; padding: 6px 10px; border-radius: 5px; text-decoration: none; }
.badge-green { display: inline-block; background: #15803d; color: white; padding: 6px 10px; border-radius: 5px; font-weight: bold; }
</style>
</head>
<body>
<h1>Authenticated Devices</h1>
HTML

print_table_header() {
    echo "<table>"
    echo "<tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>User Account</th><th>Status</th><th>Action</th><th>Advanced Control</th></tr>"
}

print_row() {
    expiry="$1"; mac="$2"; ip="$3"; hostid="$4"
    rem="$(lease_remaining "$expiry")"
    status="$(status_for_ip_mac "$ip" "$mac")"
    [ "$hostid" = "*" ] && hostid=""
    acc="$(user_for_mac "$mac")"
    echo "<tr>"
    echo "<td>$rem</td>"
    echo "<td><code>$mac</code></td>"
    echo "<td><code>$ip</code></td>"
    echo "<td>$hostid</td>"
    echo "<td>$acc</td>"
    echo "<td><span class=\"badge-green\">$status</span></td>"
    echo "<td><form action=\"/cgi-bin/deauth.sh\" method=\"get\"><input type=\"hidden\" name=\"ip\" value=\"$ip\"><button class=\"btn-red\" type=\"submit\">Remove Access</button></form></td>"
    echo "<td><a class=\"btn-blue\" href=\"/cgi-bin/device_control.sh?ip=$ip\">Advanced Control</a></td>"
    echo "</tr>"
}

OFFLINE_COUNT=0

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if in_file "$ip" "$AUTH_FILE" && ! is_online_mac "$mac"; then
            OFFLINE_COUNT=$((OFFLINE_COUNT + 1))
        fi
    done < "$LEASE_FILE"
fi

echo "<h2>Online Authenticated Devices</h2>"
print_table_header
if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if in_file "$ip" "$AUTH_FILE" && is_online_mac "$mac"; then
            print_row "$expiry" "$mac" "$ip" "$hostid"
        fi
    done < "$LEASE_FILE"
fi
echo "</table>"

if [ "$OFFLINE_COUNT" -gt 0 ]; then
    echo "<h2>Offline Authenticated Devices</h2>"
    print_table_header
    while read -r expiry mac ip hostid clientid; do
        if in_file "$ip" "$AUTH_FILE" && ! is_online_mac "$mac"; then
            print_row "$expiry" "$mac" "$ip" "$hostid"
        fi
    done < "$LEASE_FILE"
    echo "</table>"
fi

echo "</body></html>"
