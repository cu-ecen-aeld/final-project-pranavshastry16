#!/bin/sh
MAC="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^mac=//p' | head -n1 | sed 's/%3A/:/g')"
FILE="/etc/gateway/permanent_allow.list"
TMP="/tmp/perm_allow.tmp"
grep -v "^${MAC}|" "$FILE" 2>/dev/null > "$TMP" || true
mv "$TMP" "$FILE" 2>/dev/null || true
echo "Status: 302 Found"
echo "Location: /cgi-bin/permanent_allow.sh"
echo ""
