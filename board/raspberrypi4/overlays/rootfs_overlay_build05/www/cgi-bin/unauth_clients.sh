#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
TMP_AUTH="/tmp/admin_auth_ips.txt"

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

iptables -S FORWARD 2>/dev/null | awk '
/^-A FORWARD/ && /-i wlan0/ && /-o eth0/ && /-j ACCEPT/ {
    for (i=1; i<=NF; i++) if ($i=="-s") print $(i+1)
}' > "$TMP_AUTH"

is_auth() {
    ip="$1"
    grep -qx "$ip" "$TMP_AUTH" 2>/dev/null
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
.btn-yellow {
    padding: 6px 12px;
    border: none;
    border-radius: 5px;
    background: #facc15;
    color: black;
    cursor: pointer;
}
.small { color: #555; }
</style>
</head>
<body>
<h1>Unauthenticated Devices</h1>
<table>
<tr><th>Lease Remaining</th><th>MAC</th><th>IP</th><th>Hostname</th><th>Status</th><th>Action</th></tr>
HTML

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
            echo "<input type=\"hidden\" name=\"return\" value=\"unauth\">"
            echo "<button class=\"btn-yellow\" type=\"submit\">Allow Access</button>"
            echo "</form>"
            echo "</td>"
            echo "</tr>"
        fi
    done < "$LEASE_FILE"
fi

echo "</table></body></html>"
