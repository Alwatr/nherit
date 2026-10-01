#!/bin/sh
set -eu

ME=${0##*/}
MODULE=/etc/nginx/modules/ngx_http_lowercase_uri_module.so

# The module is built in the base nginx image; skip it on an older base image.
if [ ! -f "$MODULE" ]; then
  echo "$ME: WARNING: $MODULE not found, remove lowercase URI config"
  rm -fv /etc/nginx/conf.d/01-load-module-lowercase-uri.conf
  rm -fv /etc/nginx/conf.d/location.d/root.d/40-lowercase-uri.conf
  exit 0
fi

test -n "${TEST_MODE:-}" && exit 0

case "${NGINX_LOWERCASE_URI:-}" in
1 | on | true | yes | ON | On | True | TRUE | Yes | YES)
  echo "$ME: Enable lowercase URI config"
  # keep the files
  ;;
*)
  echo "$ME: Remove lowercase URI config"
  rm -fv /etc/nginx/conf.d/01-load-module-lowercase-uri.conf
  rm -fv /etc/nginx/conf.d/location.d/root.d/40-lowercase-uri.conf
  ;;
esac

exit 0
