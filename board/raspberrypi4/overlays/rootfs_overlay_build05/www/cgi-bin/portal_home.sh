#!/bin/sh
CLIENT_IP="${REMOTE_ADDR}"
MAP_DB="/etc/gateway/device_account_map.db"

is_auth() {
    grep -qx "$CLIENT_IP" /tmp/authorized_clients 2>/dev/null
}

lease_remaining() {
    expiry="$(awk -v ip="$CLIENT_IP" '$3==ip {print $1; exit}' /var/lib/misc/dnsmasq.leases 2>/dev/null)"
    now="$(date +%s 2>/dev/null)"
    [ -z "$expiry" ] && { echo "-"; return; }
    rem=$((expiry - now))
    [ "$rem" -lt 0 ] && rem=0
    hrs=$((rem / 3600))
    mins=$(((rem % 3600) / 60))
    secs=$((rem % 60))
    printf "%02dh %02dm %02ds" "$hrs" "$mins" "$secs"
}

user_for_ip() {
    mac="$(awk -v ip="$CLIENT_IP" '$3==ip {print $2; exit}' /var/lib/misc/dnsmasq.leases 2>/dev/null)"
    awk -F'|' -v m="$mac" '$2 == m { print $3; exit }' "$MAP_DB" 2>/dev/null
}

echo "Content-Type: text/html"
echo ""

if is_auth; then
    USERNAME="$(user_for_ip)"
    LEASE="$(lease_remaining)"
    cat <<HTML
<!DOCTYPE html>
<html><body style="font-family:Arial;text-align:center;padding-top:60px;background:#f4f6f8;">
<div style="width:460px;margin:auto;background:white;padding:30px;border-radius:12px;box-shadow:0 2px 10px rgba(0,0,0,0.15);">
<h1>You are logged in as "${USERNAME:--}"</h1>
<p>Remaining lease time: <b>${LEASE}</b></p>
<form action="/cgi-bin/portal_logout.sh" method="get">
<button style="padding:12px 24px;border:none;border-radius:8px;background:#b91c1c;color:white;cursor:pointer;">Logout</button>
</form>
</div>
</body></html>
HTML
else
    cat /www/index_real.html
fi
