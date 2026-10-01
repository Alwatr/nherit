#!/bin/sh

set -eu

entrypointName=${0##*/} # not ME: sourced *.envsh scripts set their own ME

entrypointDir=/etc/nginx/entrypoint.d/

echo "$entrypointName: Alwatr image v${IMAGE_VERSION:-dev} (${IMAGE_REVISION:-unknown}), nginx v${NGINX_VERSION:-unknown}"

if [ "$1" = "nginx" ] || [ "$1" = "nginx-debug" ]; then
  if /usr/bin/find "$entrypointDir" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo "$entrypointName: $entrypointDir is not empty, will attempt to perform configuration"

    echo "$entrypointName: Looking for shell scripts in $entrypointDir"
    find "$entrypointDir" -follow -type f -print | sort -V | while read -r f; do
      case "$f" in
      *.envsh)
        echo "$entrypointName: Sourcing $f"
        . "$f"
        ;;
      *.sh)
        if [ -x "$f" ]; then
          echo "$entrypointName: Launching $f"
          "$f"
        else
          # warn on shell scripts without exec bit
          echo "$entrypointName: Ignoring $f, not executable!"
        fi
        ;;
      *) echo "$entrypointName: Ignoring $f" ;;
      esac
    done

    echo "$entrypointName: Configuration complete; ready for start up"
  else
    echo "$entrypointName: No files found in $entrypointDir, skipping configuration"
  fi
fi

exec "$@"
