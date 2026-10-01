#!/bin/sh
set -eu

ME=${0##*/}

if [ -n "${NGINX_FORCE_DOMAIN:-}" ]; then
  echo "$ME: Enable force domain config to '$NGINX_FORCE_DOMAIN'"
  # keep the file
else
  echo "$ME: Remove force domain location config"
  rm -fv /etc/nginx/conf.d/location.d/root.d/30-force-domain.conf
fi

exit 0
