#!/bin/sh
echo "Content-Type: text/html"
echo ""
cat <<'HTML'
<html><body style="font-family:Arial;margin:24px;">
<h1>Create New User Account</h1>
<form action="/cgi-bin/save_new_user_account.sh" method="get">
<p>Username: <input type="text" name="user"></p>
<p>Password: <input type="text" name="pass"></p>
<p>Maximum number of devices allowed: <input type="text" name="maxdev" value="2"></p>
<p>Status:
<select name="state">
<option value="enabled">enabled</option>
<option value="disabled">disabled</option>
</select>
</p>
<button type="submit">Create</button>
</form>
</body></html>
HTML
