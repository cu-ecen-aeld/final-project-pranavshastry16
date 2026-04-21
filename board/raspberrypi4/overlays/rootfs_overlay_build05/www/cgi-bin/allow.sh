#!/bin/sh

QUERY="$QUERY_STRING"
CLIENT_IP="$(printf '%s\n' "$QUERY" | sed -n 's/.*ip=\([^&]*\).*/\1/p' | sed 's/%2E/./g')"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

if [ -n "$CLIENT_IP" ]; then
    $IPT -C FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
fi

echo "Content-Type: text/html"
echo ""
cat <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Access Allowed</title>
<meta http-equiv="refresh" content="1; url=/admin.html">
</head>
<body style="font-family: Arial, sans-serif; padding: 30px;">
<h2>Client Access Allowed</h2>
<p>Granted internet authorization for: <code>${CLIENT_IP}</code></p>
<p>Redirecting back to admin portal...</p>
</body>
</html>
HTML
