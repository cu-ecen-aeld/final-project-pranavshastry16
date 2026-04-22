#!/bin/sh

QUERY="$QUERY_STRING"
CLIENT_IP="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^ip=//p' | head -n1 | sed 's/%2E/./g')"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
BLOCK_LIST="/etc/gateway/permanent_block.list"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

AUTH_FILE="/tmp/authorized_clients"
AUTH_MANUAL="/tmp/manual_allowed_clients"

CURRENT_MAC=""
if [ -f "$LEASE_FILE" ] && [ -n "$CLIENT_IP" ]; then
    CURRENT_MAC="$(awk -v ip="$CLIENT_IP" '$3==ip {print $2; exit}' "$LEASE_FILE")"
fi

IS_BLOCKED=1
if [ -n "$CURRENT_MAC" ] && [ -f "$BLOCK_LIST" ]; then
    awk -F'|' -v m="$CURRENT_MAC" '$1 == m { found=1 } END { exit(found ? 0 : 1) }' "$BLOCK_LIST"
    IS_BLOCKED=$?
fi

if [ "$IS_BLOCKED" -eq 0 ]; then
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body style=\"font-family:Arial;padding:30px;\"><h1>Access Denied</h1><p>This device is permanently blocked.</p></body></html>"
    exit 0
fi

if [ -n "$CLIENT_IP" ]; then
    $IPT -C FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    $IPT -t nat -C PREROUTING -s "$CLIENT_IP" -i wlan0 -p tcp --dport 80 -j ACCEPT 2>/dev/null || \
    $IPT -t nat -I PREROUTING 1 -s "$CLIENT_IP" -i wlan0 -p tcp --dport 80 -j ACCEPT

    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_FILE"
    grep -qx "$CLIENT_IP" "$AUTH_MANUAL" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_MANUAL"
fi

echo "Status: 302 Found"
echo "Location: /cgi-bin/unauth_clients.sh"
echo ""
