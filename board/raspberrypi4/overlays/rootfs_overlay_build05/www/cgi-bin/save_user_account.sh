#!/bin/sh
NUM="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^num=//p' | head -n1)"
USER="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^user=//p' | head -n1 | sed 's/+/ /g')"
PASS="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^pass=//p' | head -n1 | sed 's/+/ /g')"
MAXD="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^maxdev=//p' | head -n1)"
STATE="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^state=//p' | head -n1)"

USER_DB="/etc/gateway/user_accounts.db"
TMP="/tmp/user_accounts.tmp"

awk -F'|' -v n="$NUM" -v u="$USER" -v p="$PASS" -v m="$MAXD" -v s="$STATE" '
BEGIN { OFS="|" }
$1 == n { $2=u; $3=p; $4=m; $5=s }
{ print $1,$2,$3,$4,$5 }' "$USER_DB" > "$TMP"

mv "$TMP" "$USER_DB"

echo "Status: 302 Found"
echo "Location: /cgi-bin/user_accounts.sh"
echo ""
