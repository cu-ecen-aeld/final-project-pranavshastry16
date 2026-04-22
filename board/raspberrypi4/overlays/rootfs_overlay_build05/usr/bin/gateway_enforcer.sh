#!/bin/sh

LEASE_FILE="/var/lib/misc/dnsmasq.leases"
ALLOW_LIST="/etc/gateway/permanent_allow.list"
BLOCK_LIST="/etc/gateway/permanent_block.list"

AUTH_FILE="/tmp/authorized_clients"
AUTH_PORTAL="/tmp/authenticated_clients"
AUTH_MANUAL="/tmp/manual_allowed_clients"
AUTH_PERM="/tmp/permanent_allowed_clients"
BLOCKED_FILE="/tmp/permanent_blocked_clients"

IPT="/usr/sbin/iptables"
[ -x "$IPT" ] || IPT="/sbin/iptables"
[ -x "$IPT" ] || IPT="iptables"

allow_ip() {
    ip="$1"
    $IPT -C FORWARD -s "$ip" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -s "$ip" -i wlan0 -o eth0 -j ACCEPT

    $IPT -C FORWARD -d "$ip" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
    $IPT -I FORWARD 1 -d "$ip" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
}

remove_ip() {
    ip="$1"
    while $IPT -D FORWARD -s "$ip" -i wlan0 -o eth0 -j ACCEPT 2>/dev/null; do :; done
    while $IPT -D FORWARD -d "$ip" -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; do :; done
}

remove_from_file() {
    val="$1"
    file="$2"
    tmp="${file}.tmp"
    [ -f "$file" ] || return 0
    grep -vx "$val" "$file" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$file"
}

is_in_list_by_mac() {
    mac="$1"
    file="$2"
    [ -f "$file" ] || return 1
    awk -F'|' -v m="$mac" '$1 == m { found=1 } END { exit(found ? 0 : 1) }' "$file"
}

touch "$AUTH_FILE" "$AUTH_PORTAL" "$AUTH_MANUAL" "$AUTH_PERM" "$BLOCKED_FILE"

while true; do
    : > "$AUTH_PERM"
    : > "$BLOCKED_FILE"

    if [ -f "$LEASE_FILE" ]; then
        while read -r expiry mac ip hostid clientid; do
            if is_in_list_by_mac "$mac" "$ALLOW_LIST"; then
                allow_ip "$ip"
                grep -qx "$ip" "$AUTH_FILE" 2>/dev/null || echo "$ip" >> "$AUTH_FILE"
                grep -qx "$ip" "$AUTH_PERM" 2>/dev/null || echo "$ip" >> "$AUTH_PERM"
            fi

            if is_in_list_by_mac "$mac" "$BLOCK_LIST"; then
                remove_ip "$ip"
                remove_from_file "$ip" "$AUTH_FILE"
                remove_from_file "$ip" "$AUTH_PORTAL"
                remove_from_file "$ip" "$AUTH_MANUAL"
                remove_from_file "$ip" "$AUTH_PERM"
                grep -qx "$ip" "$BLOCKED_FILE" 2>/dev/null || echo "$ip" >> "$BLOCKED_FILE"
            fi
        done < "$LEASE_FILE"
    fi

    sleep 3
done
