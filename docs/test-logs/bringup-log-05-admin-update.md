# Build 05 Admin Portal Update

## Objective
Improve the Build 05 admin portal so it can better manage connected clients.

## Changes added
- Added admin portal page for gateway management
- Added status CGI to display:
  - connected client IP addresses
  - MAC addresses
  - DHCP lease information
  - authorization state
- Added deauthorization CGI endpoint to remove internet access from a client
- Added authorization CGI endpoint to manually allow internet access for a client
- Improved client display by separating:
  - authenticated clients
  - unauthenticated clients
- Added action buttons in admin portal:
  - Remove Access
  - Allow Access
- Updated lease display logic to avoid relying on invalid absolute date/time formatting when system time is not synchronized

## Current behavior
- Client can connect to Wi-Fi
- Captive portal login flow can authorize a client
- Admin page can display connected client information
- Admin page now includes explicit per-client control actions

## Next step
- Rebuild Build 05
- Flash updated image
- Verify admin actions on target
- Add proper admin authentication for router-style login page
