#!/bin/sh
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
echo "Content-Type: text/html"
echo ""
echo "<html><body style=\"font-family:Arial;margin:24px;\"><h1>Add Device to Permanent Block</h1><table border=\"1\" cellpadding=\"8\"><tr><th>MAC</th><th>Hostname</th><th>Action</th></tr>"
while read -r expiry mac ip hostid clientid; do
    [ "$hostid" = "*" ] && hostid=""
    echo "<tr><td>$mac</td><td>$hostid</td><td><a href=\"/cgi-bin/add_permanent_block.sh?mac=$mac&host=$hostid\">Add</a></td></tr>"
done < "$LEASE_FILE"
echo "</table></body></html>"
