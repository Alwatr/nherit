#!/bin/sh
set -eu

ME=${0##*/}

test ! -d "/default-data" && exit 0

echo "$ME: Copy default data from /default-data to $NGINX_DOCUMENT_ROOT without overwriting existing files"
cp -anv /default-data/* "$NGINX_DOCUMENT_ROOT/"

exit 0
