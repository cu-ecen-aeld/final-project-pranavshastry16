#!/bin/sh
. /etc/gateway/wireless.conf
echo "Content-Type: text/html"
echo ""
cat <<HTML
<html><body style="font-family:Arial;margin:24px;">
<h1>Wireless Settings</h1>
<form action="/cgi-bin/save_wireless.sh" method="get">
<p>SSID: <input type="text" name="ssid" value="${SSID}"></p>
<p>Password: <input type="text" name="pass" value="${PASSPHRASE}"></p>
<p>Security:
<select name="security">
<option value="open">open</option>
<option value="wpa2">wpa2</option>
<option value="wpa3">wpa3</option>
</select>
</p>
<button type="submit">Save</button>
</form>
</body></html>
HTML
