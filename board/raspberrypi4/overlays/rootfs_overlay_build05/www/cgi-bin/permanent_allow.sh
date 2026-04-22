#!/bin/sh
FILE="/etc/gateway/permanent_allow.list"
echo "Content-Type: text/html"
echo ""
echo "<html><body><h1>Permanently Allowed Devices</h1><pre>"
cat "$FILE" 2>/dev/null
echo "</pre><p><a href=\"/cgi-bin/add_from_leases_allow.sh\">Add Device</a></p></body></html>"
