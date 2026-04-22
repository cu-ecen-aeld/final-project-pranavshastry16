#!/bin/sh
CLIENT_IP="${REMOTE_ADDR}"
IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

while $IPT -D FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
while $IPT -D FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done
while $IPT -t nat -D PREROUTING -s "$CLIENT_IP" -i wlan0 -p tcp --dport 80 -j ACCEPT 2>/dev/null; do :; done

for f in /tmp/authorized_clients /tmp/authenticated_clients /tmp/manual_allowed_clients /tmp/permanent_allowed_clients; do
    grep -vx "$CLIENT_IP" "$f" 2>/dev/null > /tmp/portal_logout.tmp || true
    mv /tmp/portal_logout.tmp "$f" 2>/dev/null || true
done

echo "Status: 302 Found"
echo "Location: /"
echo ""
