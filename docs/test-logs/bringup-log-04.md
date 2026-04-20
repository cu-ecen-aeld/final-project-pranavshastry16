# Bring-up Log 04

## Build 04 objective
Onboard Wi-Fi AP + DHCP + upstream routing using:
- wlan0 as guest AP interface
- eth0 as upstream interface

## Milestones achieved
- Built and booted Build 04 successfully on Raspberry Pi 4B
- Verified upstream internet access on eth0
- Enabled onboard Wi-Fi support by adding iw and Raspberry Pi Broadcom SDIO firmware
- Verified brcmfmac driver can be loaded and wlan0 appears
- Successfully started hostapd and broadcast Wi-Fi SSID
- Successfully provided DHCP leases to Wi-Fi clients using dnsmasq
- Successfully enabled IPv4 forwarding and NAT using iptables
- Verified client device internet access through the Raspberry Pi gateway

## Notes
- Image file itself was verified correct by mounting sdcard.img using losetup
- Ubuntu VM USB passthrough caused repeated SD card flashing confusion, but the Build 04 image and runtime setup were validated
- Build 04 boot automation script was also created for automatic AP gateway bring-up

## Next step
- Build 05: custom captive portal with HTTP redirect, local portal page, and client authorization flow
