#!/bin/sh

QUERY="$QUERY_STRING"
CLIENT_IP="$(printf '%s\n' "$QUERY" | sed -n 's/^ip=\(.*\)$/\1/p' | sed 's/%2E/./g')"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

if [ -n "$CLIENT_IP" ]; then
    while $IPT -D FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
    while $IPT -D FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done
done

echo "Content-Type: text/html"
echo ""
cat <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Access Removed</title>
</head>
<body style="font-family: Arial, sans-serif; padding: 30px;">
<h2>Client Access Removed</h2>
<p>Removed internet authorization for: <code>${CLIENT_IP}</code></p>
<p><a href="/admin.html">Back to Admin Portal</a></p>
</body>
</html>
HTML
