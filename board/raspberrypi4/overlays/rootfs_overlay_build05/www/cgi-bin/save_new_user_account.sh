#!/bin/sh
USER="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^user=//p' | head -n1 | sed 's/+/ /g')"
PASS="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^pass=//p' | head -n1 | sed 's/+/ /g')"
MAXD="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^maxdev=//p' | head -n1)"
STATE="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^state=//p' | head -n1)"

USER_DB="/etc/gateway/user_accounts.db"
NEXT_NUM="$(awk -F'|' 'BEGIN{m=0} $1>m {m=$1} END{print m+1}' "$USER_DB" 2>/dev/null)"
[ -z "$NEXT_NUM" ] && NEXT_NUM=1

echo "${NEXT_NUM}|${USER}|${PASS}|${MAXD}|${STATE}" >> "$USER_DB"

echo "Status: 302 Found"
echo "Location: /cgi-bin/user_accounts.sh"
echo ""
