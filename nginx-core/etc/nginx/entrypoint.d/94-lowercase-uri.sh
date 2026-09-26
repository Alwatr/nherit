#!/bin/sh
set -eu

test -n "${TEST_MODE:-}" && exit 0

ME=$(basename "$0")

case "${NGINX_LOWERCASE_URI:-}" in
1 | on | true | yes | ON | On | True | TRUE | Yes | YES)
  echo "$ME: Enable lowercase URI module"
  # keep the files
  ;;
*)
  echo "$ME: Remove lowercase URI module"
  rm -fv /etc/nginx/conf.d/01-load-module-lowercase-uri.conf
  ;;
esac

exit 0
