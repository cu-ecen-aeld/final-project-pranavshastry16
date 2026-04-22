# Build 05 Last Known Good Admin Portal Before Redirect Repair

## Milestone summary
This commit captures the last known good state of the Build 05 gateway before shifting focus to captive portal automatic redirection improvements.

## Working features verified
- Captive portal guest network available on 192.168.60.1
- Admin portal accessible on:
  - 192.168.60.1:8080
  - 192.168.60.2 redirect path
  - 192.168.1.2:8080 on WAN side
- Admin authentication working
- Authenticated / unauthenticated / devices summary views working
- Online / offline device separation working
- Permanent allow / permanent block device management working
- Device advanced control page working
- User account management working
- Account creation, configuration, disable, and delete working
- Manual device-to-account mapping working
- Captive portal user login with account credentials working
- Captive portal logged-in state and logout working
- Permanent allow and permanent block portal messages working
- Portal customization working
- Password settings working
- Wireless settings workflow working

## Next focus
- Investigate and repair automatic captive portal redirection behavior for client devices
- Preserve this commit as rollback point before redirect experiments
