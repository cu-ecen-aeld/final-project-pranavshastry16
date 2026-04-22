#!/bin/sh

QUERY="$QUERY_STRING"
USERNAME="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^username=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g')"
PASSWORD="$(printf '%s\n' "$QUERY" | tr '&' '\n' | sed -n 's/^password=//p' | head -n1 | sed 's/+/ /g; s/%20/ /g')"
CLIENT_IP="${REMOTE_ADDR}"

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
BLOCK_LIST="/etc/gateway/permanent_block.list"
USER_DB="/etc/gateway/user_accounts.db"
MAP_DB="/etc/gateway/device_account_map.db"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

AUTH_FILE="/tmp/authorized_clients"
AUTH_PORTAL="/tmp/authenticated_clients"
ERR_FILE="/tmp/login_error_message"

CURRENT_MAC=""
if [ -f "$LEASE_FILE" ] && [ -n "$CLIENT_IP" ]; then
    CURRENT_MAC="$(awk -v ip="$CLIENT_IP" '$3==ip {print $2; exit}' "$LEASE_FILE")"
fi

is_blocked_mac() {
    mac="$1"
    [ -f "$BLOCK_LIST" ] || return 1
    awk -F'|' -v m="$mac" '$1 == m { found=1 } END { exit(found ? 0 : 1) }' "$BLOCK_LIST"
}

account_exists_and_valid() {
    user="$1"
    pass="$2"
    [ -f "$USER_DB" ] || return 1
    awk -F'|' -v u="$user" -v p="$pass" '
    $2 == u && $3 == p && $5 == "enabled" { found=1 }
    END { exit(found ? 0 : 1) }' "$USER_DB"
}

count_devices_for_user() {
    user="$1"
    [ -f "$MAP_DB" ] || { echo 0; return; }
    awk -F'|' -v u="$user" '$3 == u { c++ } END { print c+0 }' "$MAP_DB"
}

max_devices_for_user() {
    user="$1"
    awk -F'|' -v u="$user" '$2 == u { print $4; exit }' "$USER_DB"
}

remove_old_mapping_for_mac() {
    mac="$1"
    tmp="/tmp/device_account_map.tmp"
    [ -f "$MAP_DB" ] || return 0
    awk -F'|' -v m="$mac" '$2 != m' "$MAP_DB" > "$tmp"
    mv "$tmp" "$MAP_DB"
}

echo "" > "$ERR_FILE"

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Please enter username and password." > "$ERR_FILE"
    echo "Status: 302 Found"
    echo "Location: /"
    echo ""
    exit 0
fi

if [ -n "$CURRENT_MAC" ] && is_blocked_mac "$CURRENT_MAC"; then
    echo "This device is permanently blocked." > "$ERR_FILE"
    echo "Status: 302 Found"
    echo "Location: /"
    echo ""
    exit 0
fi

if ! account_exists_and_valid "$USERNAME" "$PASSWORD"; then
    echo "Invalid username or password." > "$ERR_FILE"
    echo "Status: 302 Found"
    echo "Location: /"
    echo ""
    exit 0
fi

MAX_DEV="$(max_devices_for_user "$USERNAME")"
CUR_DEV="$(count_devices_for_user "$USERNAME")"

if [ -n "$CURRENT_MAC" ]; then
    # If this MAC already belongs to this user, don't count it as new
    EXISTING_USER="$(awk -F'|' -v m="$CURRENT_MAC" '$2 == m { print $3; exit }' "$MAP_DB" 2>/dev/null)"
    if [ "$EXISTING_USER" != "$USERNAME" ] && [ "$CUR_DEV" -ge "$MAX_DEV" ]; then
        echo "Maximum allowed devices reached for this account." > "$ERR_FILE"
        echo "Status: 302 Found"
        echo "Location: /"
        echo ""
        exit 0
    fi
fi

if [ -n "$CLIENT_IP" ]; then
    $IPT -C FORWARD -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$CLIENT_IP" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$CLIENT_IP" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    grep -qx "$CLIENT_IP" "$AUTH_FILE" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_FILE"
    grep -qx "$CLIENT_IP" "$AUTH_PORTAL" 2>/dev/null || echo "$CLIENT_IP" >> "$AUTH_PORTAL"
fi

if [ -n "$CURRENT_MAC" ]; then
    remove_old_mapping_for_mac "$CURRENT_MAC"
    echo "${CLIENT_IP}|${CURRENT_MAC}|${USERNAME}" >> "$MAP_DB"
fi

echo "Content-Type: text/html"
echo ""
cat /www/success.html
