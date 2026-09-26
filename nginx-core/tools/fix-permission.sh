#!/bin/sh

set -eu

for arg in "$@"; do
  case "${arg}" in
    -h|--help)
      echo "Usage: $0 [target_directory]"
      echo "Default directory: \$NGINX_DOCUMENT_ROOT"
      exit 0
      ;;
  esac
done

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

# Fix file and directory permissions to the standard state for nginx.
# Directories -> 755, files -> 644.
# Target path is taken from the first argument, or falls back to NGINX_DOCUMENT_ROOT.

DOCUMENT_ROOT="${1:-${NGINX_DOCUMENT_ROOT:-}}"

if [ -z "${DOCUMENT_ROOT}" ]; then
  echoError "Error: no path provided and NGINX_DOCUMENT_ROOT environment variable is not set"
  exit 1
fi

if [ ! -d "${DOCUMENT_ROOT}" ]; then
  echoError "Error: Directory ${DOCUMENT_ROOT} does not exist"
  exit 1
fi

echoStep "Fixing directory permissions (755) in ${DOCUMENT_ROOT} ..."

# Directories: 755 (rwxr-xr-x) - only change if not already 755
find "${DOCUMENT_ROOT}" -type d ! -perm 755 -exec chmod -v 755 {} +

echoStep "Fixing file permissions (644) in ${DOCUMENT_ROOT} ..."

# Files: 644 (rw-r--r--) - only change if not already 644
find "${DOCUMENT_ROOT}" -type f ! -perm 644 -exec chmod -v 644 {} +

echoDone 'Permissions fixed!'
