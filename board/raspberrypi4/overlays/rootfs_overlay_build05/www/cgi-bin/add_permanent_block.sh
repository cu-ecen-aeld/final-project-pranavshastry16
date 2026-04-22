#!/bin/sh
QUERY="$QUERY_STRING"
MAC="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^mac=//p' | head -n1 | sed 's/%3A/:/g')"
HOST="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^host=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g; s/%2D/-/g')"

ALLOW="/etc/gateway/permanent_allow.list"
BLOCK="/etc/gateway/permanent_block.list"

grep -v "^${MAC}|" "$ALLOW" 2>/dev/null > /tmp/allow.tmp || true
mv /tmp/allow.tmp "$ALLOW" 2>/dev/null || true

grep -v "^${MAC}|" "$BLOCK" 2>/dev/null > /tmp/block_old.tmp || true
mv /tmp/block_old.tmp "$BLOCK" 2>/dev/null || true
echo "${MAC}|${HOST}|1" >> "$BLOCK"

echo "Status: 302 Found"
echo "Location: /cgi-bin/permanent_devices.sh"
echo ""
