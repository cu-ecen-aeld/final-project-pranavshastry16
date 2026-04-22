#!/bin/sh
IP="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^ip=//p' | head -n1 | sed 's/%2E/./g')"
MAC="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^mac=//p' | head -n1 | sed 's/%3A/:/g')"

ALLOW="/etc/gateway/permanent_allow.list"
TMP="/tmp/perm_allow_revoke.tmp"

grep -v "^${MAC}|" "$ALLOW" 2>/dev/null > "$TMP" || true
mv "$TMP" "$ALLOW" 2>/dev/null || true

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

while $IPT -D FORWARD -s "$IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
while $IPT -D FORWARD -d "$IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done

for f in /tmp/authorized_clients /tmp/authenticated_clients /tmp/manual_allowed_clients /tmp/permanent_allowed_clients; do
    grep -vx "$IP" "$f" 2>/dev/null > /tmp/revoke_perm.tmp || true
    mv /tmp/revoke_perm.tmp "$f" 2>/dev/null || true
done

echo "Status: 302 Found"
echo "Location: /cgi-bin/auth_clients.sh"
echo ""
