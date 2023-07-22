#!/bin/sh
DOMAIN="p.njupt.edu.cn"
HTTP_PORT=801
LOGOUT_PATH="/eportal/portal/logout?callback=drcom"

curl "http://${DOMAIN}:${HTTP_PORT}${LOGOUT_PATH}"