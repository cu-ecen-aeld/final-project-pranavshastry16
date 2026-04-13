# Bring-up Log 03

## Progress completed
- Created separate milestone output directory for gateway/NAT stage
- Enabled dnsmasq with DHCP support
- Enabled dropbear
- Enabled iptables
- Enabled iproute2
- Built gateway/NAT milestone image for Raspberry Pi 4B

## Next step
- Flash Build 3 image to SD card
- Boot Raspberry Pi 4B
- Verify eth0 presence and link state
- Test dnsmasq-based DHCP assignment over Ethernet
- Prepare for routing/NAT validation with upstream interface
