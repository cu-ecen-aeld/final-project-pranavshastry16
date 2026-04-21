#!/bin/sh

QUERY="$QUERY_STRING"
CLIENT_IP="$(printf '%s\n' "$QUERY" | sed -n 's/.*ip=\([^&]*\).*/\1/p' | sed 's/%2E/./g')"
RETURN_PAGE="$(printf '%s\n' "$QUERY" | sed -n 's/.*return=\([^&]*\).*/\1/p')"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

if [ -n "$CLIENT_IP" ]; then
    $IPT -C FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
fi

[ "$RETURN_PAGE" = "unauth" ] || RETURN_PAGE="auth_clients"

echo "Content-Type: text/html"
echo ""
cat <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="0; url=/cgi-bin/unauth_clients.sh">
<title>Access Allowed</title>
</head>
<body></body>
</html>
HTML
