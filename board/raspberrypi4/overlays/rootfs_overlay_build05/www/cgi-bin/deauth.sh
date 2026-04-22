#!/bin/sh

QUERY="$QUERY_STRING"
CLIENT_IP="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^ip=//p' | head -n1 | sed 's/%2E/./g')"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

AUTH_FILE="/tmp/authorized_clients"
TMP_FILE="/tmp/authorized_clients.tmp"

if [ -n "$CLIENT_IP" ]; then
    while $IPT -D FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
    while $IPT -D FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done
    while $IPT -t nat -D PREROUTING -s "$CLIENT_IP" -i wlan0 -p tcp --dport 80 -j ACCEPT 2>/dev/null; do :; done

    if [ -f "$AUTH_FILE" ]; then
        grep -vx "$CLIENT_IP" "$AUTH_FILE" > "$TMP_FILE" 2>/dev/null || true
        mv "$TMP_FILE" "$AUTH_FILE"
    fi

    for f in /tmp/authenticated_clients /tmp/manual_allowed_clients /tmp/permanent_allowed_clients; do
        grep -vx "$CLIENT_IP" "$f" 2>/dev/null > /tmp/deauth.tmp || true
        mv /tmp/deauth.tmp "$f" 2>/dev/null || true
    done
fi

echo "Content-Type: text/html"
echo ""
cat <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="0; url=/cgi-bin/auth_clients.sh">
<title>Access Removed</title>
</head>
<body></body>
</html>
HTML
