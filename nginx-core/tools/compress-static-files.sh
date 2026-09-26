#!/bin/sh

set -eu

FORCE=false

for arg in "$@"; do
  case "${arg}" in
    -f|--force)
      FORCE=true
      ;;
    -h|--help)
      echo "Usage: $0 [-f|--force]"
      exit 0
      ;;
  esac
done

echoColor() {
  # 0: gray, 1: red, 2: green, 3: yellow, 4: blue, 5: purple, 6: cyan, 7: white
  local colorCode="\x1b[0;3${1:-7}m"
  local message="${2:-}"
  local reset="\x1b[0m"
  printf "${colorCode}${message}${reset}"
}

echoStep() {
  local message="${1:-}"
  echoColor 6 "\n🔸 ${message}\n\n"
}

echoDone() {
  local message=${1:-'Done ;)'}
  echoColor 2 "\n✅ ${message}\n\n"
}

echoError() {
  local message=${1:-'Error :('}
  echoColor 1 "❌ ${message}\n\n"
}

# Compress all files in NGINX_DOCUMENT_ROOT recursively with Brotli
# for use with nginx brotli_static module

if [ -z "${NGINX_DOCUMENT_ROOT:-}" ]; then
  echoError "Error: NGINX_DOCUMENT_ROOT environment variable is not set"
  exit 1
fi

if [ ! -d "${NGINX_DOCUMENT_ROOT}" ]; then
  echoError "Error: Directory ${NGINX_DOCUMENT_ROOT} does not exist"
  exit 1
fi

if ! command -v brotli >/dev/null 2>&1; then
  echoStep "Installing brotli..."
  apk add --no-cache brotli
fi

if [ "${FORCE}" = "true" ]; then
  echoStep "Compressing files in ${NGINX_DOCUMENT_ROOT} with Brotli (force overwrite)..."
else
  echoStep "Compressing files in ${NGINX_DOCUMENT_ROOT} with Brotli (skipping existing)..."
fi

# Find and compress text-based files
# Skip already compressed files (.br, .gz, etc.)
find "${NGINX_DOCUMENT_ROOT}" -type f \
  \( -name "*.html" -o -name "*.css" -o -name "*.js" \
  -o -name "*.json" -o -name "*.xml" -o -name "*.svg" \
  -o -name "*.csv" -o -name "*.yml" -o -name "*.yaml" \
  -o -name "*.txt" -o -name "*.md" -o -name "*.wasm" \
  -o -name "*.woff" -o -name "*.ttf" -o -name "*.otf" -o -name "*.eot" \
  -o -name "*.rss" -o -name "*.atom" \) \
  ! -name "*.br" ! -name "*.gz" |
  while IFS= read -r file; do
    if [ "${FORCE}" != "true" ] && [ -e "${file}.br" ]; then
      continue
    fi
    echoStep "Compressing: ${file}"
    brotli --best --squash --verbose --lgwin=0 --keep --suffix=.br --force "${file}"
  done

echoDone 'Compression complete!'

echoColor 3 "Ensure \$NGINX_BROTLI_STATIC is set to 'on' (currently set to '${NGINX_BROTLI_STATIC:-off}')."
