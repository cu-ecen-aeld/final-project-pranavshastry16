#!/bin/sh
. /etc/gateway/portal.conf
echo "Content-Type: text/html"
echo ""
printf '%s\n' "${PORTAL_TITLE}"
