#!/bin/sh

CLIENT_IP="${REMOTE_ADDR}"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
BLOCK_LIST="/etc/gateway/permanent_block.list"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

AUTH_FILE="/tmp/authorized_clients"
AUTH_PORTAL="/tmp/authenticated_clients"

CURRENT_MAC=""
if [ -f "$LEASE_FILE" ] && [ -n "$CLIENT_IP" ]; then
    CURRENT_MAC="$(awk -v ip="$CLIENT_IP" '$3==ip {print $2; exit}' "$LEASE_FILE")"
fi

IS_BLOCKED=1
if [ -n "$CURRENT_MAC" ] && [ -f "$BLOCK_LIST" ]; then
    awk -F'|' -v m="$CURRENT_MAC" '
    NF >= 2 && $2 == m { found=1 }
    NF == 1 && $1 == m { found=1 }
    END { exit(found ? 0 : 1) }' "$BLOCK_LIST"
    IS_BLOCKED=$?
fi

echo "Content-Type: text/html"
echo ""

if [ "$IS_BLOCKED" -eq 0 ]; then
    cat <<HTML
<!DOCTYPE html>
<html><body style="font-family:Arial;padding:30px;">
<h1>Access Denied</h1>
<p>This device is permanently blocked from internet access.</p>
</body></html>
HTML
    exit 0
fi

if [ -n "$CLIENT_IP" ]; then
    $IPT -C FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_FILE"
    grep -qx "$CLIENT_IP" "$AUTH_PORTAL" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_PORTAL"
fi

cat /www/success.html
