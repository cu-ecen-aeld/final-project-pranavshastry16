#!/bin/sh
QUERY="$QUERY_STRING"
MAC="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^mac=//p' | head -n1 | sed 's/%3A/:/g')"
HOST="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^host=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g; s/%2D/-/g')"

ALLOW="/etc/gateway/permanent_allow.list"
BLOCK="/etc/gateway/permanent_block.list"

grep -v "^${MAC}|" "$ALLOW" 2>/dev/null > /tmp/allow.tmp || true
mv /tmp/allow.tmp "$ALLOW" 2>/dev/null || true

grep -q "^${MAC}|" "$BLOCK" 2>/dev/null || echo "${MAC}|${HOST}" >> "$BLOCK"

echo "Status: 302 Found"
echo "Location: /cgi-bin/permanent_block.sh"
echo ""
