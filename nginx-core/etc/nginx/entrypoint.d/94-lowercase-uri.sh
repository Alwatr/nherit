#!/bin/sh
set -eu

test -n "${TEST_MODE:-}" && exit 0

ME=$(basename "$0")

case "${NGINX_LOWERCASE_URI:-}" in
1 | on | true | yes | ON | On | True | TRUE | Yes | YES)
  echo "$ME: Enable lowercase URI redirect config"
  # keep the files
  ;;
*)
  echo "$ME: Remove lowercase URI redirect config"
  rm -fv /etc/nginx/conf.d/01-load-module-njs.conf
  rm -fv /etc/nginx/conf.d/http.d/43-map-lowercase-uri.conf
  rm -fv /etc/nginx/conf.d/location.d/45-lowercase-uri.conf
  ;;
esac

exit 0
