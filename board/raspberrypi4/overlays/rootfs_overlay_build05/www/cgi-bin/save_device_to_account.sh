#!/bin/sh
DEVICE="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^device=//p' | head -n1 | sed 's/%3A/:/g')"
MANUALMAC="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^manualmac=//p' | head -n1 | sed 's/%3A/:/g')"
USER="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^user=//p' | head -n1 | sed 's/+/ /g')"

MAP_DB="/etc/gateway/device_account_map.db"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
AUTH_FILE="/tmp/authorized_clients"
AUTH_MANUAL="/tmp/manual_allowed_clients"

MAC="$DEVICE"
[ -n "$MANUALMAC" ] && MAC="$MANUALMAC"

IP="$(awk -v m="$MAC" '$2==m {print $3; exit}' "$LEASE_FILE" 2>/dev/null)"

awk -F'|' -v m="$MAC" '$2 != m' "$MAP_DB" > /tmp/map_add.tmp 2>/dev/null || true
mv /tmp/map_add.tmp "$MAP_DB" 2>/dev/null || true
echo "${IP}|${MAC}|${USER}" >> "$MAP_DB"

if [ -n "$IP" ]; then
    IPT="/usr/sbin/iptables"
    [ -x "$IPT" ] || IPT="/sbin/iptables"
    [ -x "$IPT" ] || IPT="iptables"

    $IPT -C FORWARD -s "$IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || $IPT -I FORWARD 1 -s "$IP" -i wlan0 -o eth0 -j ACCEPT
    $IPT -C FORWARD -d "$IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || $IPT -I FORWARD 1 -d "$IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    grep -qx "$IP" "$AUTH_FILE" 2>/dev/null || echo "$IP" >> "$AUTH_FILE"
    grep -qx "$IP" "$AUTH_MANUAL" 2>/dev/null || echo "$IP" >> "$AUTH_MANUAL"
fi

echo "Status: 302 Found"
echo "Location: /cgi-bin/auth_clients.sh"
echo ""
