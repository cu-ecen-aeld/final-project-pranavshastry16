#!/bin/sh
. /etc/gateway/portal.conf
SAVED="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^saved=//p' | head -n1)"

echo "Content-Type: text/html"
echo ""
cat <<HTML
<html><body style="font-family:Arial;margin:24px;">
<h1>Portal Customization</h1>
HTML
[ "$SAVED" = "1" ] && echo '<p style="color:green;font-weight:bold;">Changes saved.</p>'
cat <<HTML
<p>Note: this build supports selecting a logo path already present on the device.</p>
<form action="/cgi-bin/save_portal.sh" method="get">
<p>Portal Title:<br><input type="text" name="title" value="${PORTAL_TITLE}" style="width:520px;height:34px;"></p>
<p>Portal Subtitle:<br><textarea name="subtitle" style="width:520px;height:90px;">${PORTAL_SUBTITLE}</textarea></p>
<p>Logo Path:<br><input type="text" value="${PORTAL_LOGO}" readonly style="width:520px;background:#f3f4f6;"></p>
<input type="hidden" name="logo" value="${PORTAL_LOGO}">
<button type="submit">Save Portal Settings</button>
</form>
</body></html>
HTML
