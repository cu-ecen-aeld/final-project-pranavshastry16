#!/bin/sh
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
USER_DB="/etc/gateway/user_accounts.db"

echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html>
<head>
<script>
function useManualMac() {
    document.getElementById('device').selectedIndex = -1;
    document.getElementById('manualmacrow').style.display = 'block';
}
</script>
</head>
<body style="font-family:Arial;margin:24px;">
<h1>Add Device Manually</h1>
<form action="/cgi-bin/save_device_to_account.sh" method="get">
<p>Select Device:
<select id="device" name="device" size="1">
<option value="">-- Select Device --</option>
HTML

while read -r expiry mac ip hostid clientid; do
    [ "$hostid" = "*" ] && hostid=""
    echo "<option value=\"$mac\">$mac ${hostid}</option>"
done < "$LEASE_FILE"

cat <<'HTML'
</select>
</p>

<p><button type="button" onclick="useManualMac()">Add manually using MAC address</button></p>
<p id="manualmacrow" style="display:none;">MAC Address: <input type="text" name="manualmac" placeholder="FF:FF:FF:FF:FF:FF"></p>

<p>Select User Account:
<select name="user">
HTML

awk -F'|' '$5 == "enabled" { print $2 }' "$USER_DB" | while read -r user; do
    echo "<option value=\"$user\">$user</option>"
done

cat <<'HTML'
</select>
</p>

<button type="submit">Save</button>
</form>
</body>
</html>
HTML
