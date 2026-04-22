#!/bin/sh

CLIENT_IP="${REMOTE_ADDR}"

if [ -x /usr/sbin/iptables ]; then
    IPT=/usr/sbin/iptables
elif [ -x /sbin/iptables ]; then
    IPT=/sbin/iptables
else
    IPT=iptables
fi

AUTH_FILE="/tmp/authorized_clients"

if [ -n "$CLIENT_IP" ]; then
    $IPT -C FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    touch "$AUTH_FILE"
    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_FILE"
fi

echo "Content-Type: text/html"
echo ""
cat /www/success.html
