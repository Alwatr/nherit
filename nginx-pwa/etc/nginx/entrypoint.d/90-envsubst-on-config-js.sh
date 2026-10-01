#!/bin/sh
# vim:sw=2:ts=2:sts=2:et

set -eu

ME=${0##*/}

test -z "${NGINX_CONFIG_JS_URI:-}" && exit 0;

configJsPath="$NGINX_DOCUMENT_ROOT/${NGINX_CONFIG_JS_URI:-}";
if test ! -f "$configJsPath";
then
  echo "$ME: ERROR: $configJsPath does not exist";
  exit 1
fi

definedEnvs=$(printf '${%s} ' $(env | cut -d= -f1));
if [ ! -w "$configJsPath" ];
then
  echo "$ME: ERROR: $configJsPath exists, but is not writable";
  exit 1
fi

echo "$ME: Running envsubst on $configJsPath";
envsubst "$definedEnvs" <"$configJsPath" >"${configJsPath}.tmp";
mv -f "${configJsPath}.tmp" "$configJsPath";

exit 0;
