#!/bin/sh
ALLOW="/etc/gateway/permanent_allow.list"
BLOCK="/etc/gateway/permanent_block.list"

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html>
<head>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.banner-green { background:#dcfce7; padding:14px; border-radius:8px; margin-bottom:18px; font-size:28px; font-weight:bold; width:100%; }
.banner-red { background:#fee2e2; padding:14px; border-radius:8px; margin:28px 0 18px 0; font-size:28px; font-weight:bold; width:100%; }
table { border-collapse: collapse; width: 100%; background:white; margin-bottom:18px; }
th, td { border:1px solid #ccc; padding:8px; text-align:left; }
th { background:#f0f0f0; }
.btn { display:inline-block; background:#2563eb; color:white; padding:8px 12px; border-radius:6px; text-decoration:none; margin-bottom:16px; }
.btn-red { display:inline-block; background:#b91c1c; color:white; padding:6px 10px; border-radius:6px; text-decoration:none; }
</style>
</head>
<body>
<div class="banner-green">Permanently Allowed Devices</div>
<a class="btn" href="/cgi-bin/add_from_leases_allow.sh">Add Device</a>
<table>
<tr><th>MAC</th><th>Hostname</th><th>Action</th></tr>
HTML

if [ -f "$ALLOW" ]; then
    while IFS='|' read -r mac host; do
        [ -z "$mac" ] && continue
        echo "<tr><td>$mac</td><td>$host</td><td><a class=\"btn-red\" href=\"/cgi-bin/remove_permanent_allow.sh?mac=$mac\">Remove</a></td></tr>"
    done < "$ALLOW"
fi

cat <<'HTML'
</table>
<div class="banner-red">Permanently Blocked Devices</div>
<a class="btn" href="/cgi-bin/add_from_leases_block.sh">Add Device</a>
<table>
<tr><th>MAC</th><th>Hostname</th><th>Action</th></tr>
HTML

if [ -f "$BLOCK" ]; then
    while IFS='|' read -r mac host; do
        [ -z "$mac" ] && continue
        echo "<tr><td>$mac</td><td>$host</td><td><a class=\"btn-red\" href=\"/cgi-bin/remove_permanent_block.sh?mac=$mac\">Remove</a></td></tr>"
    done < "$BLOCK"
fi

echo "</table></body></html>"
