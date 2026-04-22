#!/bin/sh
QUERY="$QUERY_STRING"
USER="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^user=//p' | head -n1)"
PASS="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^pass=//p' | head -n1)"

[ -z "$USER" ] && USER="admin"
[ -z "$PASS" ] && PASS="aesdadmin"

echo "${USER}:${PASS}" > /etc/lighttpd/admin.user

echo "Status: 302 Found"
echo "Location: /cgi-bin/password_settings.sh?saved=1"
echo ""
