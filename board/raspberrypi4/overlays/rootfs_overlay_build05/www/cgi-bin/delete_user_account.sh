#!/bin/sh
NUM="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^num=//p' | head -n1)"
USER_DB="/etc/gateway/user_accounts.db"
MAP_DB="/etc/gateway/device_account_map.db"

USER="$(awk -F'|' -v n="$NUM" '$1 == n { print $2; exit }' "$USER_DB")"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

awk -F'|' -v u="$USER" '$3 == u { print $1 }' "$MAP_DB" 2>/dev/null | while read -r ip; do
    [ -z "$ip" ] && continue
    while $IPT -D FORWARD -s "$ip" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
    while $IPT -D FORWARD -d "$ip" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done

    grep -vx "$ip" /tmp/authorized_clients 2>/dev/null > /tmp/auth_del1.tmp || true
    mv /tmp/auth_del1.tmp /tmp/authorized_clients 2>/dev/null || true
    grep -vx "$ip" /tmp/authenticated_clients 2>/dev/null > /tmp/auth_del2.tmp || true
    mv /tmp/auth_del2.tmp /tmp/authenticated_clients 2>/dev/null || true
    grep -vx "$ip" /tmp/manual_allowed_clients 2>/dev/null > /tmp/auth_del3.tmp || true
    mv /tmp/auth_del3.tmp /tmp/manual_allowed_clients 2>/dev/null || true
done

awk -F'|' -v n="$NUM" '$1 != n' "$USER_DB" > /tmp/user_db.tmp
mv /tmp/user_db.tmp "$USER_DB"

awk -F'|' -v u="$USER" '$3 != u' "$MAP_DB" > /tmp/map_db.tmp
mv /tmp/map_db.tmp "$MAP_DB"

echo "Status: 302 Found"
echo "Location: /cgi-bin/user_accounts.sh"
echo ""
