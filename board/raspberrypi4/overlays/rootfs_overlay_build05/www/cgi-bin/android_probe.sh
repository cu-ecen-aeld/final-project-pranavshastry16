#!/bin/sh

CLIENT_IP="${REMOTE_ADDR}"
AUTH_FILE="/tmp/authorized_clients"

is_auth() {
    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null
}

if is_auth; then
    echo "Status: 204 No Content"
    echo ""
else
    echo "Content-Type: text/html"
    echo ""
    cat <<HTML
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="refresh" content="0; url=http://192.168.60.1/">
<title>Redirecting</title>
</head>
<body>
Redirecting to captive portal...
</body>
</html>
HTML
fi
