# Bring-up Log 02 and 03

## Milestone 2 achieved
- Booted the `02_eth_dhcp` image successfully on Raspberry Pi 4B
- Verified `eth0` detection on the Pi
- Observed Ethernet link establishment
- Assigned static IP `192.168.50.1/24` to `eth0`
- Started `dnsmasq` successfully
- Connected client received DHCP lease from Raspberry Pi
- Client successfully pinged the Raspberry Pi

## Milestone 3 achieved
- Booted the `03_gateway_nat` image successfully on Raspberry Pi 4B
- Verified presence of `dnsmasq`
- Verified presence of `iptables`
- Verified presence of `iproute2`
- Confirmed IPv4 forwarding can be enabled by writing `1` to `/proc/sys/net/ipv4/ip_forward`

## Next step
- Build 04: onboard Wi-Fi AP + DHCP + upstream routing using `wlan0` as guest/AP side and `eth0` as upstream side
