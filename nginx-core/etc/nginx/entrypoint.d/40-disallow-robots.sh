#!/bin/sh

set -eu

ME=${0##*/}

case "${NGINX_DISALLOW_ROBOTS:-}" in
1 | on | true | yes | ON | On | True | TRUE | Yes | YES)
  echo "$ME: Replace robots.txt to disallow all robots"
  cp -afv /default-data/robots.txt $NGINX_DOCUMENT_ROOT/
  ;;
*)
  echo "$ME: skipping robots.txt replacement"
  ;;
esac

exit 0
