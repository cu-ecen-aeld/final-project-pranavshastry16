#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
TMP_STATIONS="/tmp/admin_stations.txt"
TMP_AUTH="/tmp/admin_auth.txt"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

echo "Content-Type: text/html"
echo ""

cat <<'HTML'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Gateway Status</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h2 { margin-top: 30px; }
table { border-collapse: collapse; width: 100%; margin-top: 10px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
code { background: #f7f7f7; padding: 2px 4px; }
form { margin: 0; }
button { padding: 6px 10px; border: none; border-radius: 5px; background: #b71c1c; color: white; cursor: pointer; }
button:hover { background: #8e0000; }
.small { color: #666; font-size: 13px; }
</style>
</head>
<body>
HTML

HOSTNAME="$(hostname 2>/dev/null)"
ETH_IP="$(ip -4 addr show eth0 2>/dev/null | awk '/inet /{print $2}')"
WLAN_IP="$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2}')"

echo "<h2>Gateway Summary</h2>"
echo "<p><b>Hostname:</b> <code>${HOSTNAME}</code><br>"
echo "<b>eth0:</b> <code>${ETH_IP}</code><br>"
echo "<b>wlan0:</b> <code>${WLAN_IP}</code></p>"

iw dev wlan0 station dump 2>/dev/null > "$TMP_STATIONS"

$IPT -L FORWARD -n 2>/dev/null | awk '/ACCEPT/ && /wlan0/ && /eth0/ {print $4}' > "$TMP_AUTH"

echo "<h2>DHCP Leases</h2>"
echo "<table>"
echo "<tr><th>Expiry</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Authorized</th><th>Action</th></tr>"

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        AUTH="No"
        if grep -qx "$ip" "$TMP_AUTH" 2>/dev/null; then
            AUTH="Yes"
        fi

        if [ "$hostid" = "*" ]; then
            hostid=""
        fi

        EXP_HUMAN="$(date -d "@$expiry" 2>/dev/null)"
        [ -n "$EXP_HUMAN" ] || EXP_HUMAN="$expiry"

        echo "<tr>"
        echo "<td>$EXP_HUMAN</td>"
        echo "<td><code>$mac</code></td>"
        echo "<td><code>$ip</code></td>"
        echo "<td>$hostid</td>"
        echo "<td>$AUTH</td>"
        echo "<td>"
        echo "<form action=\"/cgi-bin/deauth.sh\" method=\"get\">"
        echo "<input type=\"hidden\" name=\"ip\" value=\"$ip\">"
        echo "<button type=\"submit\">Remove Access</button>"
        echo "</form>"
        echo "</td>"
        echo "</tr>"
    done < "$LEASE_FILE"
else
    echo "<tr><td colspan=\"6\">No lease file found.</td></tr>"
fi

echo "</table>"

echo "<h2>Associated Wi-Fi Stations</h2>"
if [ -s "$TMP_STATIONS" ]; then
    echo "<pre>"
    cat "$TMP_STATIONS"
    echo "</pre>"
else
    echo "<p class=\"small\">No station data available.</p>"
fi

echo "</body></html>"
