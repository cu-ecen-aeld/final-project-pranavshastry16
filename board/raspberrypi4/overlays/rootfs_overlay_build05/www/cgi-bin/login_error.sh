#!/bin/sh
ERR_FILE="/tmp/login_error_message"
echo "Content-Type: text/html"
echo ""
if [ -f "$ERR_FILE" ]; then
    msg="$(cat "$ERR_FILE" 2>/dev/null)"
    [ -n "$msg" ] && printf '<div class="error">%s</div>\n' "$msg"
fi
