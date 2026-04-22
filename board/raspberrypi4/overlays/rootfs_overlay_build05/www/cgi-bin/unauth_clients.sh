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
h1 { margin-top: 0; }
table { border-collapse: collapse; width: 100%; }
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
<table>
<tr><th>Time Left</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th><th>Advanced Control</th></tr>
HTML

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if ! in_file "$ip" "$AUTH_FILE"; then
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
        fi
    done < "$LEASE_FILE"
fi

echo "</table></body></html>"
