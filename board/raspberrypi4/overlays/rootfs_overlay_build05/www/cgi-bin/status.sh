#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
TMP_AUTH="/tmp/admin_auth.txt"
TMP_STATIONS="/tmp/admin_stations.txt"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

lease_remaining() {
    expiry="$1"
    now="$(date +%s 2>/dev/null)"
    [ -n "$now" ] || now=0

    rem=$((expiry - now))
    [ "$rem" -lt 0 ] && rem=0

    days=$((rem / 86400))
    hours=$(((rem % 86400) / 3600))
    mins=$(((rem % 3600) / 60))

    if [ "$days" -gt 0 ]; then
        echo "${days}d ${hours}h"
    elif [ "$hours" -gt 0 ]; then
        echo "${hours}h ${mins}m"
    else
        echo "${mins}m"
    fi
}

is_auth() {
    ip="$1"
    grep -qx "$ip" "$TMP_AUTH" 2>/dev/null
}

echo "Content-Type: text/html"
echo ""

$IPT -S FORWARD 2>/dev/null | awk '
/-A FORWARD/ && /-i wlan0/ && /-o eth0/ && /-j ACCEPT/ {
    for (i=1; i<=NF; i++) if ($i=="-s") print $(i+1)
}' > "$TMP_AUTH"

iw dev wlan0 station dump 2>/dev/null > "$TMP_STATIONS"

cat <<'HTML'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Gateway Status</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h2 { margin-top: 30px; }
table { border-collapse: collapse; width: 100%; margin-top: 10px; margin-bottom: 25px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
code { background: #f7f7f7; padding: 2px 4px; }
form { margin: 0; }
.btn-red {
    padding: 6px 10px; border: none; border-radius: 5px;
    background: #b71c1c; color: white; cursor: pointer;
}
.btn-yellow {
    padding: 6px 10px; border: none; border-radius: 5px;
    background: #f9a825; color: black; cursor: pointer;
}
.badge-green {
    display: inline-block; padding: 6px 10px; border-radius: 5px;
    background: #2e7d32; color: white; font-weight: bold;
}
.small { color: #666; font-size: 13px; }
pre { background: #f8f8f8; padding: 10px; overflow-x: auto; }
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

echo "<h2>Authenticated Clients</h2>"
echo "<table>"
echo "<tr><th>Lease Remaining</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th></tr>"

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if is_auth "$ip"; then
            [ "$hostid" = "*" ] && hostid=""
            rem="$(lease_remaining "$expiry")"
            echo "<tr>"
            echo "<td>$rem</td>"
            echo "<td><code>$mac</code></td>"
            echo "<td><code>$ip</code></td>"
            echo "<td>$hostid</td>"
            echo "<td><span class=\"badge-green\">Connected</span></td>"
            echo "<td>"
            echo "<form action=\"/cgi-bin/deauth.sh\" method=\"get\">"
            echo "<input type=\"hidden\" name=\"ip\" value=\"$ip\">"
            echo "<button class=\"btn-red\" type=\"submit\">Remove Access</button>"
            echo "</form>"
            echo "</td>"
            echo "</tr>"
        fi
    done < "$LEASE_FILE"
fi

echo "</table>"

echo "<h2>Unauthenticated Clients</h2>"
echo "<table>"
echo "<tr><th>Lease Remaining</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th></tr>"

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if ! is_auth "$ip"; then
            [ "$hostid" = "*" ] && hostid=""
            rem="$(lease_remaining "$expiry")"
            echo "<tr>"
            echo "<td>$rem</td>"
            echo "<td><code>$mac</code></td>"
            echo "<td><code>$ip</code></td>"
            echo "<td>$hostid</td>"
            echo "<td class=\"small\">Not authorized</td>"
            echo "<td>"
            echo "<form action=\"/cgi-bin/allow.sh\" method=\"get\">"
            echo "<input type=\"hidden\" name=\"ip\" value=\"$ip\">"
            echo "<button class=\"btn-yellow\" type=\"submit\">Allow Access</button>"
            echo "</form>"
            echo "</td>"
            echo "</tr>"
        fi
    done < "$LEASE_FILE"
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
