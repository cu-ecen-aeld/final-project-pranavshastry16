#!/bin/sh
#
# Example startup script to bring up Raspberry Pi onboard Wi-Fi
# as an access point using brcmfmac + hostapd
#

case "$1" in
    start)
        echo "[INFO] Loading Broadcom Wi-Fi driver"
        modprobe brcmfmac
        sleep 2

        echo "[INFO] Bringing wlan0 up"
        ip link set wlan0 up

        echo "[INFO] Assigning AP IP address"
        ip addr flush dev wlan0 2>/dev/null
        ip addr add 192.168.60.1/24 dev wlan0

        echo "[INFO] Starting hostapd"
        killall hostapd 2>/dev/null
        hostapd -B /etc/hostapd.conf
        ;;

    stop)
        echo "[INFO] Stopping hostapd"
        killall hostapd 2>/dev/null

        echo "[INFO] Bringing wlan0 down"
        ip link set wlan0 down 2>/dev/null
        ;;

    restart)
        $0 stop
        sleep 1
        $0 start
        ;;

    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0