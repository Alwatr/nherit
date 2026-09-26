#!/bin/sh

set -eu

FORCE=false
WEBP_QUALITY="${WEBP_QUALITY:-78}"
TARGET_DIR=""

for arg in "$@"; do
  case "${arg}" in
    -f|--force)
      FORCE=true
      ;;
    -h|--help)
      echo "Usage: $0 [-f|--force] [quality (1-100, default: 78)] [target_directory]"
      echo "Default directory: \$NGINX_DOCUMENT_ROOT"
      exit 0
      ;;
    [0-9]*)
      WEBP_QUALITY="${arg}"
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

# Compress all images in DOCUMENT_ROOT recursively to WebP
# for use with nginx auto-webp feature

if [ -z "${DOCUMENT_ROOT}" ]; then
  echoError "Error: no path provided and NGINX_DOCUMENT_ROOT environment variable is not set"
  exit 1
fi

if [ ! -d "${DOCUMENT_ROOT}" ]; then
  echoError "Error: Directory ${DOCUMENT_ROOT} does not exist"
  exit 1
fi

if ! command -v cwebp >/dev/null 2>&1; then
  echoStep "Installing libwebp..."
  apk add --no-cache libwebp-tools
fi

if [ "${FORCE}" = "true" ]; then
  echoStep "Compressing images in ${DOCUMENT_ROOT} with WebP (quality: ${WEBP_QUALITY}, force overwrite)..."
else
  echoStep "Compressing images in ${DOCUMENT_ROOT} with WebP (quality: ${WEBP_QUALITY}, skipping existing)..."
fi

# Find and compress image files.
# The loop below handles skipping already compressed files.
find "${DOCUMENT_ROOT}" -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
  -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.tif" \) \
  ! -iname "*.webp" | {
  COMPRESSED_COUNT=0
  SKIPPED_COUNT=0
  ERROR_COUNT=0

  while IFS= read -r file; do
    if [ "${FORCE}" != "true" ] && [ -e "${file}.webp" ]; then
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      continue
    fi
    echoStep "Compressing: ${file}"
    if cwebp -mt -m 6 -af -v -q "${WEBP_QUALITY}" "${file}" -o "${file}.webp"; then
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

echoColor 3 "Ensure \$NGINX_AUTO_WEBP is set to 'on' (currently set to '${NGINX_AUTO_WEBP:-off}').\n"
