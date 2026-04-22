#!/bin/sh

CLIENT_IP="${REMOTE_ADDR}"
AUTH_FILE="/tmp/authorized_clients"

is_auth() {
    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null
}

echo "Content-Type: text/html"
echo ""

if is_auth; then
    cat <<HTML
<HTML><HEAD><TITLE>Success</TITLE></HEAD><BODY>Success</BODY></HTML>
HTML
else
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
