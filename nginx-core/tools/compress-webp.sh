#!/bin/sh

set -eu

FORCE=false
WEBP_QUALITY="${WEBP_QUALITY:-78}"

for arg in "$@"; do
  case "${arg}" in
    -f|--force)
      FORCE=true
      ;;
    -h|--help)
      echo "Usage: $0 [-f|--force] [quality (1-100, default: 78)]"
      exit 0
      ;;
    [0-9]*)
      WEBP_QUALITY="${arg}"
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

# Compress all images in NGINX_DOCUMENT_ROOT recursively to WebP
# for use with nginx auto-webp feature

if [ -z "${NGINX_DOCUMENT_ROOT:-}" ]; then
  echoError "Error: NGINX_DOCUMENT_ROOT environment variable is not set"
  exit 1
fi

if [ ! -d "${NGINX_DOCUMENT_ROOT}" ]; then
  echoError "Error: Directory ${NGINX_DOCUMENT_ROOT} does not exist"
  exit 1
fi

if ! command -v cwebp >/dev/null 2>&1; then
  echoStep "Installing libwebp..."
  apk add --no-cache libwebp-tools
fi

if [ "${FORCE}" = "true" ]; then
  echoStep "Compressing images in ${NGINX_DOCUMENT_ROOT} with WebP (quality: ${WEBP_QUALITY}, force overwrite)..."
else
  echoStep "Compressing images in ${NGINX_DOCUMENT_ROOT} with WebP (quality: ${WEBP_QUALITY}, skipping existing)..."
fi

# Find and compress image files.
# The loop below handles skipping already compressed files.
find "${NGINX_DOCUMENT_ROOT}" -type f \
  \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \
  -o -name "*.gif" -o -name "*.tiff" -o -name "*.tif" \) \
  ! -name "*.webp" |
  while IFS= read -r file; do
    if [ "${FORCE}" != "true" ] && [ -e "${file}.webp" ]; then
      continue
    fi
    echoStep "Compressing: ${file}"
    cwebp -mt -m 6 -af -v -q "${WEBP_QUALITY}" "${file}" -o "${file}.webp"
  done

echoDone 'Compression complete!'

echoColor 3 "Ensure \$NGINX_AUTO_WEBP is set to 'on' (currently set to '${NGINX_AUTO_WEBP:-off}')."
