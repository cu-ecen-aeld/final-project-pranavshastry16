#!/bin/sh
echo "Status: 401 Unauthorized"
echo "WWW-Authenticate: Basic realm=\"AESD Gateway Admin\""
echo "Content-Type: text/html"
echo ""
echo "<html><body><h1>Logged out</h1><p>Close the browser or clear auth cache if your browser keeps the session.</p></body></html>"
