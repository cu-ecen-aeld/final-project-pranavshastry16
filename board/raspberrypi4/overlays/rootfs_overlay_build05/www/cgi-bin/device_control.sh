#!/bin/sh

QUERY="$QUERY_STRING"
IP="$(printf '%s\n' "$QUERY" | sed -n 's/.*ip=\([^&]*\).*/\1/p' | sed 's/%2E/./g')"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"

MAC=""
HOSTID=""
EXPIRY=""

if [ -f "$LEASE_FILE" ]; then
    while read -r expiry mac ip hostid clientid; do
        if [ "$ip" = "$IP" ]; then
            MAC="$mac"
            HOSTID="$hostid"
            EXPIRY="$expiry"
            break
        fi
    done < "$LEASE_FILE"
fi

echo "Content-Type: text/html"
echo ""
cat <<HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Device Advanced Control</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.box { background:white; padding:20px; border-radius:10px; box-shadow:0 2px 8px rgba(0,0,0,0.12); }
button { padding:8px 12px; border:none; border-radius:6px; cursor:pointer; margin-right:10px; }
.blue { background:#2563eb; color:white; }
.red { background:#b91c1c; color:white; }
.green { background:#15803d; color:white; }
</style>
</head>
<body>
<div class="box">
<h1>Advanced Control</h1>
<p><b>Name:</b> ${HOSTID}</p>
<p><b>MAC Address:</b> ${MAC}</p>
<p><b>IP Address:</b> ${IP}</p>
<p><b>DHCP Lease Expiry Raw:</b> ${EXPIRY}</p>

<h3>Modify DHCP Lease</h3>
<form action="/cgi-bin/set_lease.sh" method="get">
<input type="hidden" name="ip" value="${IP}">
<label>Enter the new DHCP lease time in hours from now:</label><br><br>
<input type="text" name="hours" placeholder="e.g. 12">
<button class="blue" type="submit">Modify</button>
</form>

<h3>Permanent Access</h3>
<p>Blacklist device: ban internet access to this device.</p>
<form action="/cgi-bin/add_permanent_block.sh" method="get">
<input type="hidden" name="ip" value="${IP}">
<input type="hidden" name="mac" value="${MAC}">
<input type="hidden" name="host" value="${HOSTID}">
<button class="red" type="submit">Blacklist Device</button>
</form>

<p>Whitelist device: allow internet access permanently.</p>
<form action="/cgi-bin/add_permanent_allow.sh" method="get">
<input type="hidden" name="ip" value="${IP}">
<input type="hidden" name="mac" value="${MAC}">
<input type="hidden" name="host" value="${HOSTID}">
<button class="green" type="submit">Whitelist Device</button>
</form>
</div>
</body>
</html>
HTML
