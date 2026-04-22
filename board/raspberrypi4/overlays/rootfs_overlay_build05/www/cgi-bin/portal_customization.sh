#!/bin/sh
. /etc/gateway/portal.conf
echo "Content-Type: text/html"
echo ""
cat <<HTML
<html><body style="font-family:Arial;margin:24px;">
<h1>Portal Customization</h1>
<p>Note: this build supports selecting a logo path already present on the device, not true browser file upload yet.</p>
<form action="/cgi-bin/save_portal.sh" method="get">
<p>Portal Title: <input type="text" name="title" value="${PORTAL_TITLE}"></p>
<p>Portal Subtitle: <input type="text" name="subtitle" value="${PORTAL_SUBTITLE}"></p>
<p>Logo Path: <input type="text" name="logo" value="${PORTAL_LOGO}"></p>
<button type="submit">Save Portal Settings</button>
</form>
</body></html>
HTML
