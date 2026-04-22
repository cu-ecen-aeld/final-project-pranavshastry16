#!/bin/sh
USER_DB="/etc/gateway/user_accounts.db"
MAP_DB="/etc/gateway/device_account_map.db"

count_devices() {
    user="$1"
    [ -f "$MAP_DB" ] || { echo 0; return; }
    awk -F'|' -v u="$user" '$3 == u { c++ } END { print c+0 }' "$MAP_DB"
}

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html>
<head>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; background: white; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background: #f0f0f0; }
.btn-blue { display:inline-block; background:#2563eb; color:white; padding:6px 10px; border-radius:6px; text-decoration:none; }
</style>
</head>
<body>
<h1>User Account Management</h1>
<table>
<tr><th>Account Number</th><th>Username</th><th>Connected Devices</th><th>Enabled or Disabled</th><th>Configure</th></tr>
HTML

if [ -f "$USER_DB" ]; then
    while IFS='|' read -r num user pass maxdev state; do
        [ -z "$num" ] && continue
        cnt="$(count_devices "$user")"
        echo "<tr><td>$num</td><td>$user</td><td>$cnt</td><td>$state</td><td><a class=\"btn-blue\" href=\"/cgi-bin/user_account_config.sh?num=$num\">Configure</a></td></tr>"
    done < "$USER_DB"
fi

echo "</table></body></html>"
