#!/bin/sh
QUERY="$QUERY_STRING"
TITLE="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^title=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g; s/%2D/-/g; s/%2F/\//g')"
SUB="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^subtitle=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g; s/%2D/-/g; s/%2F/\//g')"
LOGO="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^logo=//p' | head -n1 | sed 's/+/ /g; s/%2F/\//g')"

cat > /etc/gateway/portal.conf <<CFG
PORTAL_TITLE="${TITLE}"
PORTAL_SUBTITLE="${SUB}"
PORTAL_LOGO="${LOGO}"
CFG

echo "Status: 302 Found"
echo "Location: /cgi-bin/portal_customization.sh?saved=1"
echo ""
