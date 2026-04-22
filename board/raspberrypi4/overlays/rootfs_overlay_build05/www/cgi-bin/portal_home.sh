#!/bin/sh
CLIENT_IP="${REMOTE_ADDR}"
MAP_DB="/etc/gateway/device_account_map.db"
AUTH_FILE="/tmp/authorized_clients"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
ALLOW_LIST="/etc/gateway/permanent_allow.list"
BLOCK_LIST="/etc/gateway/permanent_block.list"

mac_for_ip() {
    awk -v ip="$CLIENT_IP" '$3==ip {print $2; exit}' "$LEASE_FILE" 2>/dev/null
}

is_auth() {
    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null
}

lease_remaining() {
    expiry="$(awk -v ip="$CLIENT_IP" '$3==ip {print $1; exit}' "$LEASE_FILE" 2>/dev/null)"
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
    mac="$(mac_for_ip)"
    awk -F'|' -v m="$mac" '$2 == m { print $3; exit }' "$MAP_DB" 2>/dev/null
}

in_mac_list() {
    mac="$1"
    file="$2"
    [ -f "$file" ] || return 1
    awk -F'|' -v m="$mac" '$1 == m { found=1 } END { exit(found ? 0 : 1) }' "$file"
}

block_showmsg() {
    mac="$1"
    [ -f "$BLOCK_LIST" ] || return 1
    awk -F'|' -v m="$mac" '$1 == m { print $3; exit }' "$BLOCK_LIST"
}

echo "Content-Type: text/html"
echo ""

MAC="$(mac_for_ip)"
USERNAME="$(user_for_ip)"

if [ -n "$MAC" ] && in_mac_list "$MAC" "$ALLOW_LIST"; then
    cat <<HTML
<!DOCTYPE html>
<html><body style="font-family:Arial;text-align:center;padding-top:60px;background:#f4f6f8;">
<div style="width:460px;margin:auto;background:white;padding:30px;border-radius:12px;box-shadow:0 2px 10px rgba(0,0,0,0.15);">
<h1>Your device is whitelisted - permanently allowed!</h1>
<p>Remaining lease time: <b>$(lease_remaining)</b></p>
</div>
</body></html>
HTML
    exit 0
fi

if [ -n "$MAC" ] && in_mac_list "$MAC" "$BLOCK_LIST"; then
    SHOW="$(block_showmsg "$MAC")"
    if [ "$SHOW" = "1" ] || [ -z "$SHOW" ]; then
        cat <<HTML
<!DOCTYPE html>
<html><body style="font-family:Arial;text-align:center;padding-top:60px;background:#f4f6f8;">
<div style="width:460px;margin:auto;background:white;padding:30px;border-radius:12px;box-shadow:0 2px 10px rgba(0,0,0,0.15);">
<h1>Your device has been permanently blocked.</h1>
<p>Please contact system administrator.</p>
</div>
</body></html>
HTML
        exit 0
    fi
fi

if is_auth && [ -n "$USERNAME" ] && [ "$USERNAME" != "-" ]; then
    LEASE="$(lease_remaining)"
    cat <<HTML
<!DOCTYPE html>
<html><body style="font-family:Arial;text-align:center;padding-top:60px;background:#f4f6f8;">
<div style="width:460px;margin:auto;background:white;padding:30px;border-radius:12px;box-shadow:0 2px 10px rgba(0,0,0,0.15);">
<h1>You are logged in as ${USERNAME}</h1>
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
