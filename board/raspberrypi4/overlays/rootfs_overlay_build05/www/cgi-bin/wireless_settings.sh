#!/bin/sh
. /etc/gateway/wireless.conf
SAVED="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^saved=//p' | head -n1)"

OPEN_SEL=""
WPA2_SEL=""
WPA3_SEL=""
[ "$SECURITY" = "open" ] && OPEN_SEL="selected"
[ "$SECURITY" = "wpa2" ] && WPA2_SEL="selected"
[ "$SECURITY" = "wpa3" ] && WPA3_SEL="selected"

echo "Content-Type: text/html"
echo ""
cat <<HTML
<html><body style="font-family:Arial;margin:24px;">
<h1>Wireless Settings</h1>
HTML
[ "$SAVED" = "1" ] && echo '<p style="color:green;font-weight:bold;">System is restarting... may take up to 1 minute.</p>'
cat <<HTML
<form action="/cgi-bin/save_wireless.sh" method="get">
<p>SSID: <input type="text" name="ssid" value="${SSID}"></p>
<p>Password: <input type="text" name="pass" value="${PASSPHRASE}"></p>
<p>Security:
<select name="security">
<option value="open" $OPEN_SEL>open</option>
<option value="wpa2" $WPA2_SEL>wpa2</option>
<option value="wpa3" $WPA3_SEL>wpa3</option>
</select>
</p>
<button type="submit">Save and Restart</button>
</form>
</body></html>
HTML
