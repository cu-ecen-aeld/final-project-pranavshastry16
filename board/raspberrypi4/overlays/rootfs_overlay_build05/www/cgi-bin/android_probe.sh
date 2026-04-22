#!/bin/sh

CLIENT_IP="${REMOTE_ADDR}"
AUTH_FILE="/tmp/authorized_clients"

is_auth() {
    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null
}

if is_auth; then
    echo "Status: 204 No Content"
    echo "Content-Length: 0"
    echo "Cache-Control: no-cache, no-store, must-revalidate"
    echo "Pragma: no-cache"
    echo "Expires: 0"
    echo ""
else
    echo "Status: 302 Found"
    echo "Location: http://192.168.60.1/"
    echo "Cache-Control: no-cache, no-store, must-revalidate"
    echo "Pragma: no-cache"
    echo "Expires: 0"
    echo ""
fi
