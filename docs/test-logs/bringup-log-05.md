# Bring-up Log 05

## Build 05 objective
Custom captive portal build on top of the working automated AP gateway.

## Build 05 additions
- Added lighttpd web server
- Added captive portal landing page
- Added CGI login/accept handler
- Added Build 05 specific overlay
- Added captive portal init script
- Planned HTTP redirect for unauthenticated clients

## Base inherited from Build 04
- Automatic AP startup on boot
- DHCP service on wlan0
- Upstream routing through eth0
- NAT using iptables
