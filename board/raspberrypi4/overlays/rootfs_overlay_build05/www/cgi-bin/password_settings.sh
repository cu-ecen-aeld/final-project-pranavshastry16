#!/bin/sh
SAVED="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^saved=//p' | head -n1)"
echo "Content-Type: text/html"
echo ""
cat <<HTML
<html><body style="font-family:Arial;margin:24px;">
<h1>Password Settings</h1>
HTML
[ "$SAVED" = "1" ] && echo '<p style="color:green;font-weight:bold;">Changes saved.</p>'
cat <<HTML
<form action="/cgi-bin/save_password.sh" method="get">
<p>Admin Username: <input type="text" name="user" value="admin"></p>
<p>New Password: <input type="text" name="pass" value=""></p>
<button type="submit">Save Password</button>
</form>
</body></html>
HTML
