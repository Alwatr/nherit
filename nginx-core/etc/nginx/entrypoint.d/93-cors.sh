#!/bin/sh
set -eu

test -n "${TEST_MODE:-}" && exit 0

ME=${0##*/}

case "${NGINX_CORS_ENABLE:-}" in
1 | on | true | yes | ON | On | True | TRUE | Yes | YES)
  echo "$ME: Enable CORS config"
  # keep the file
  ;;
*)
  echo "$ME: Remove CORS config"
  rm -fv /etc/nginx/conf.d/location.d/root.d/10-cors.conf
  ;;
esac

exit 0
