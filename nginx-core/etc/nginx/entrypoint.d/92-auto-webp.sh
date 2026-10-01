#!/bin/sh
set -eu

test -n "${TEST_MODE:-}" && exit 0

ME=${0##*/}

case "${NGINX_AUTO_WEBP:-}" in
1 | on | true | yes | ON | On | True | TRUE | Yes | YES)
  echo "$ME: Enable auto WebP config"
  # keep the file
  ;;
*)
  echo "$ME: Remove auto WebP config"
  rm -fv /etc/nginx/conf.d/http.d/42-map-webp.conf
  rm -fv /etc/nginx/conf.d/location.d/50-webp.conf
  ;;
esac

exit 0
