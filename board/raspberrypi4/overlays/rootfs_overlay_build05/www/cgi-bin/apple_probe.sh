#!/bin/sh

CLIENT_IP="${REMOTE_ADDR}"
AUTH_FILE="/tmp/authorized_clients"

is_auth() {
    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null
}

if is_auth; then
    echo "Content-Type: text/html"
    echo "Cache-Control: no-cache, no-store, must-revalidate"
    echo "Pragma: no-cache"
    echo "Expires: 0"
    echo ""
    cat <<HTML
<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>
HTML
else
    echo "Status: 302 Found"
    echo "Location: http://192.168.60.1/"
    echo "Cache-Control: no-cache, no-store, must-revalidate"
    echo "Pragma: no-cache"
    echo "Expires: 0"
    echo ""
fi
