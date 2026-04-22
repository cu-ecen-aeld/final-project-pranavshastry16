#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
AUTH_FILE="/tmp/authorized_clients"
AUTH_PORTAL="/tmp/authenticated_clients"
AUTH_MANUAL="/tmp/manual_allowed_clients"
AUTH_PERM="/tmp/permanent_allowed_clients"
BLOCKED_FILE="/tmp/permanent_blocked_clients"
ALLOW_LIST="/etc/gateway/permanent_allow.list"
BLOCK_LIST="/etc/gateway/permanent_block.list"
MAP_DB="/etc/gateway/device_account_map.db"

is_online_mac() {
    mac="$1"
    iw dev wlan0 station dump 2>/dev/null | awk '/^Station / {print $2}' | grep -iq "^${mac}$"
}

in_file() {
    val="$1"
    file="$2"
    grep -qx "$val" "$file" 2>/dev/null
}

in_mac_list() {
    mac="$1"
    file="$2"
    [ -f "$file" ] || return 1
    awk -F'|' -v m="$mac" '$1 == m { found=1 } END { exit(found ? 0 : 1) }' "$file"
}

status_for_ip_mac() {
    ip="$1"
    mac="$2"

    if in_mac_list "$mac" "$BLOCK_LIST" || in_file "$ip" "$BLOCKED_FILE"; then
        echo "Permanently Blocked"
    elif in_mac_list "$mac" "$ALLOW_LIST" || in_file "$ip" "$AUTH_PERM"; then
        echo "Permanently Allowed"
    elif in_file "$ip" "$AUTH_MANUAL"; then
        echo "Manually Allowed"
    elif in_file "$ip" "$AUTH_PORTAL"; then
        echo "Authenticated"
    elif in_file "$ip" "$AUTH_FILE"; then
        echo "Connected"
    else
        echo "Unauthenticated"
    fi
}

lease_remaining() {
    expiry="$1"
    now="$(date +%s 2>/dev/null)"
    [ -n "$now" ] || now=0
    rem=$((expiry - now))
    [ "$rem" -lt 0 ] && rem=0
    hrs=$((rem / 3600))
    mins=$(((rem % 3600) / 60))
    secs=$((rem % 60))
    printf "%02dh %02dm %02ds" "$hrs" "$mins" "$secs"
}

user_for_mac() {
    mac="$1"
    if in_mac_list "$mac" "$ALLOW_LIST"; then
        echo "-"
        return
    fi
    [ -f "$MAP_DB" ] || return
    awk -F'|' -v m="$mac" '$2 == m { print $3; exit }' "$MAP_DB"
}
