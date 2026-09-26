#!/bin/sh

set -eu

FORCE=false
TARGET_DIR=""

for arg in "$@"; do
  case "${arg}" in
    -f|--force)
      FORCE=true
      ;;
    -h|--help)
      echo "Usage: $0 [-f|--force] [target_directory]"
      echo "Default directory: \$NGINX_DOCUMENT_ROOT"
      exit 0
      ;;
    -*)
      echo "Error: Unknown option ${arg}" >&2
      exit 1
      ;;
    *)
      if [ -z "${TARGET_DIR}" ]; then
        TARGET_DIR="${arg}"
      fi
      ;;
  esac
done

DOCUMENT_ROOT="${TARGET_DIR:-${NGINX_DOCUMENT_ROOT:-}}"

echoColor() {
  # 0: gray, 1: red, 2: green, 3: yellow, 4: blue, 5: purple, 6: cyan, 7: white
  local colorCode="\033[0;3${1:-7}m"
  local message="${2:-}"
  local reset="\033[0m"
  printf "%b%b%b" "${colorCode}" "${message}" "${reset}"
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

# Compress all files in DOCUMENT_ROOT recursively with Brotli
# for use with nginx brotli_static module

if [ -z "${DOCUMENT_ROOT}" ]; then
  echoError "Error: no path provided and NGINX_DOCUMENT_ROOT environment variable is not set"
  exit 1
fi

if [ ! -d "${DOCUMENT_ROOT}" ]; then
  echoError "Error: Directory ${DOCUMENT_ROOT} does not exist"
  exit 1
fi

if ! command -v brotli >/dev/null 2>&1; then
  echoStep "Installing brotli..."
  apk add --no-cache brotli
fi

if [ "${FORCE}" = "true" ]; then
  echoStep "Compressing files in ${DOCUMENT_ROOT} with Brotli (force overwrite)..."
else
  echoStep "Compressing files in ${DOCUMENT_ROOT} with Brotli (skipping existing)..."
fi

# Find and compress text-based files
# Skip already compressed files (.br, .gz, etc.)
find "${DOCUMENT_ROOT}" -type f \
  \( -iname "*.html" -o -iname "*.htm" -o -iname "*.css" -o -iname "*.js" \
  -o -iname "*.mjs" -o -iname "*.cjs" -o -iname "*.json" -o -iname "*.xml" \
  -o -iname "*.svg" -o -iname "*.csv" -o -iname "*.yml" -o -iname "*.yaml" \
  -o -iname "*.txt" -o -iname "*.md" -o -iname "*.wasm" -o -iname "*.ico" \
  -o -iname "*.woff" -o -iname "*.ttf" -o -iname "*.otf" -o -iname "*.eot" \
  -o -iname "*.rss" -o -iname "*.atom" -o -iname "*.map" -o -iname "*.webmanifest" \) \
  ! -iname "*.br" ! -iname "*.gz" | {
  COMPRESSED_COUNT=0
  SKIPPED_COUNT=0
  ERROR_COUNT=0

  while IFS= read -r file; do
    if [ "${FORCE}" != "true" ] && [ -e "${file}.br" ]; then
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      continue
    fi
    echoStep "Compressing: ${file}"
    if brotli --best --squash --verbose --lgwin=0 --keep --suffix=.br --force "${file}"; then
      COMPRESSED_COUNT=$((COMPRESSED_COUNT + 1))
    else
      echoError "Failed to compress: ${file}"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
  done

  if [ "${ERROR_COUNT}" -gt 0 ]; then
    echoError "Compression completed with errors: ${COMPRESSED_COUNT} compressed, ${SKIPPED_COUNT} skipped, ${ERROR_COUNT} failed."
    exit 1
  else
    echoDone "Compression complete! (${COMPRESSED_COUNT} compressed, ${SKIPPED_COUNT} skipped)"
  fi
}

echoColor 3 "Ensure \$NGINX_BROTLI_STATIC is set to 'on' (currently set to '${NGINX_BROTLI_STATIC:-off}').\n"
