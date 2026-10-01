#!/bin/sh
set -eu

ME=${0##*/}

# 40-lowercase-uri.conf already has the PWA try_files; keep only one try_files in the root location.
if [ -f /etc/nginx/conf.d/location.d/root.d/40-lowercase-uri.conf ]; then
  echo "$ME: Lowercase URI is enabled, remove PWA try_files config"
  rm -fv /etc/nginx/conf.d/location.d/root.d/90-pwa.conf
fi

exit 0
