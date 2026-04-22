#!/bin/sh
QUERY="$QUERY_STRING"
MAC="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^mac=//p' | head -n1 | sed 's/%3A/:/g')"
HOST="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^host=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g; s/%2D/-/g')"

ALLOW="/etc/gateway/permanent_allow.list"
BLOCK="/etc/gateway/permanent_block.list"
MAP_DB="/etc/gateway/device_account_map.db"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"

AUTH_FILE="/tmp/authorized_clients"
AUTH_PERM="/tmp/permanent_allowed_clients"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

# Remove same MAC from block list
grep -v "^${MAC}|" "$BLOCK" 2>/dev/null > /tmp/block.tmp || true
mv /tmp/block.tmp "$BLOCK" 2>/dev/null || true

# Remove same MAC from device-account mapping
if [ -f "$MAP_DB" ]; then
    awk -F'|' -v m="$MAC" '$2 != m' "$MAP_DB" > /tmp/map.tmp
    mv /tmp/map.tmp "$MAP_DB"
fi

# Remove any old copy from allow list, then add normalized MAC|HOST
grep -v "^${MAC}|" "$ALLOW" 2>/dev/null > /tmp/allow.tmp || true
mv /tmp/allow.tmp "$ALLOW" 2>/dev/null || true
echo "${MAC}|${HOST}" >> "$ALLOW"

# If the device is currently online and has a lease, allow immediately by IP too
IP="$(awk -v m="$MAC" '$2==m {print $3; exit}' "$LEASE_FILE" 2>/dev/null)"

if [ -n "$IP" ]; then
    $IPT -C FORWARD -s "$IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    $IPT -t nat -C PREROUTING -s "$IP" -i wlan0 -p tcp --dport 80 -j ACCEPT 2>/dev/null || \
    $IPT -t nat -I PREROUTING 1 -s "$IP" -i wlan0 -p tcp --dport 80 -j ACCEPT

    grep -qx "$IP" "$AUTH_FILE" 2>/dev/null || echo "$IP" >> "$AUTH_FILE"
    grep -qx "$IP" "$AUTH_PERM" 2>/dev/null || echo "$IP" >> "$AUTH_PERM"
fi

echo "Status: 302 Found"
echo "Location: /cgi-bin/permanent_devices.sh"
echo ""
