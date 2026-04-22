#!/bin/sh
NUM="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^num=//p' | head -n1)"
USER="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^user=//p' | head -n1 | sed 's/+/ /g')"
PASS="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^pass=//p' | head -n1 | sed 's/+/ /g')"
MAXD="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^maxdev=//p' | head -n1)"
STATE="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^state=//p' | head -n1)"

USER_DB="/etc/gateway/user_accounts.db"
MAP_DB="/etc/gateway/device_account_map.db"
TMP="/tmp/user_accounts.tmp"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

awk -F'|' -v n="$NUM" -v u="$USER" -v p="$PASS" -v m="$MAXD" -v s="$STATE" '
BEGIN { OFS="|" }
$1 == n { $2=u; $3=p; $4=m; $5=s }
{ print $1,$2,$3,$4,$5 }' "$USER_DB" > "$TMP"

mv "$TMP" "$USER_DB"

if [ "$STATE" = "disabled" ]; then
    awk -F'|' -v u="$USER" '$3 == u { print $1 }' "$MAP_DB" 2>/dev/null | while read -r ip; do
        [ -z "$ip" ] && continue
        while $IPT -D FORWARD -s "$ip" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
        while $IPT -D FORWARD -d "$ip" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done
        grep -vx "$ip" /tmp/authorized_clients 2>/dev/null > /tmp/auth1.tmp || true
        mv /tmp/auth1.tmp /tmp/authorized_clients 2>/dev/null || true
        grep -vx "$ip" /tmp/authenticated_clients 2>/dev/null > /tmp/auth2.tmp || true
        mv /tmp/auth2.tmp /tmp/authenticated_clients 2>/dev/null || true
        grep -vx "$ip" /tmp/manual_allowed_clients 2>/dev/null > /tmp/auth3.tmp || true
        mv /tmp/auth3.tmp /tmp/manual_allowed_clients 2>/dev/null || true
    done
fi

echo "Status: 302 Found"
echo "Location: /cgi-bin/user_accounts.sh"
echo ""
