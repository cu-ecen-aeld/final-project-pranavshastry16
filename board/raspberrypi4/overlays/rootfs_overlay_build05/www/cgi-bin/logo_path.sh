#!/bin/sh
. /etc/gateway/portal.conf
echo "Status: 302 Found"
echo "Location: ${PORTAL_LOGO}"
echo ""
