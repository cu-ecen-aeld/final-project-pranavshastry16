#!/bin/sh
NUM="$(printf '%s\n' "$QUERY_STRING" | tr '&' '\n' | sed -n 's/^num=//p' | head -n1)"
USER_DB="/etc/gateway/user_accounts.db"

ROW="$(awk -F'|' -v n="$NUM" '$1 == n { print $0; exit }' "$USER_DB")"
ACC_NUM="$(printf '%s\n' "$ROW" | cut -d'|' -f1)"
ACC_USER="$(printf '%s\n' "$ROW" | cut -d'|' -f2)"
ACC_PASS="$(printf '%s\n' "$ROW" | cut -d'|' -f3)"
ACC_MAX="$(printf '%s\n' "$ROW" | cut -d'|' -f4)"
ACC_STATE="$(printf '%s\n' "$ROW" | cut -d'|' -f5)"

EN_SEL=""
DIS_SEL=""
[ "$ACC_STATE" = "enabled" ] && EN_SEL="selected"
[ "$ACC_STATE" = "disabled" ] && DIS_SEL="selected"

echo "Content-Type: text/html"
echo ""
cat <<HTML
<html><body style="font-family:Arial;margin:24px;">
<h1>Configure User Account</h1>
<form action="/cgi-bin/save_user_account.sh" method="get">
<input type="hidden" name="num" value="$ACC_NUM">
<p>Username: <input type="text" name="user" value="$ACC_USER"></p>
<p>Password: <input type="text" name="pass" value="$ACC_PASS"></p>
<p>Maximum number of devices allowed: <input type="text" name="maxdev" value="$ACC_MAX"></p>
<p>Status:
<select name="state">
<option value="enabled" $EN_SEL>enabled</option>
<option value="disabled" $DIS_SEL>disabled</option>
</select>
</p>
<button type="submit">Save</button>
</form>
</body></html>
HTML
