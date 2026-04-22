#!/bin/sh
FILE="/etc/gateway/permanent_block.list"

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html>
<head>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.banner { background:#fee2e2; padding:14px; border-radius:8px; margin-bottom:18px; font-size:28px; font-weight:bold; width:100%; }
table { border-collapse: collapse; width: 100%; background:white; }
th, td { border:1px solid #ccc; padding:8px; text-align:left; }
th { background:#f0f0f0; }
.btn { display:inline-block; background:#2563eb; color:white; padding:8px 12px; border-radius:6px; text-decoration:none; margin-bottom:16px; }
.btn-red { display:inline-block; background:#b91c1c; color:white; padding:6px 10px; border-radius:6px; text-decoration:none; }
</style>
</head>
<body>
<div class="banner">Permanently Blocked Devices</div>
<a class="btn" href="/cgi-bin/add_from_leases_block.sh">Add Device</a>
<table>
<tr><th>MAC</th><th>Hostname</th><th>Action</th></tr>
HTML

if [ -f "$FILE" ]; then
    while IFS='|' read -r mac host; do
        [ -z "$mac" ] && continue
        echo "<tr><td>$mac</td><td>$host</td><td><a class=\"btn-red\" href=\"/cgi-bin/remove_permanent_block.sh?mac=$mac\">Remove</a></td></tr>"
    done < "$FILE"
fi

echo "</table></body></html>"
