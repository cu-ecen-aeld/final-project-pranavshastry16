#!/bin/sh
MAC="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^mac=//p' | head -n1 | sed 's/%3A/:/g')"
SHOW="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^showmsg=//p' | head -n1)"
BLOCK="/etc/gateway/permanent_block.list"
TMP="/tmp/block_toggle.tmp"

[ "$SHOW" = "1" ] && VAL="1" || VAL="0"

awk -F'|' -v m="$MAC" -v v="$VAL" '
BEGIN { OFS="|" }
$1 == m { $3=v }
{ print $1,$2,$3 }' "$BLOCK" > "$TMP"

mv "$TMP" "$BLOCK"

echo "Status: 302 Found"
echo "Location: /cgi-bin/permanent_devices.sh"
echo ""
