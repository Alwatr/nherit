#!/bin/sh
# Release a new version: bump the Alwatr base images in all Dockerfiles, commit, tag and create the GitHub release.
# Remember: change logs are generated from pull requests, do not push hotfix directly to the default branch.
#
# Usage: ./release.sh <patch|minor|major|X.Y.Z>

set -eu

cd "$(dirname "$0")"

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean, commit or stash first." >&2
  exit 1
fi

git checkout next
git pull

current_version=$(sed -n 's#^FROM ghcr.io/alwatr/nginx:\([0-9.]*\).*#\1#p' nginx-core/Dockerfile)

IFS=. read -r major minor patch <<EOF
$current_version
EOF

case "${1:-}" in
patch) new_version="$major.$minor.$((patch + 1))" ;;
minor) new_version="$major.$((minor + 1)).0" ;;
major) new_version="$((major + 1)).0.0" ;;
[0-9]*.[0-9]*.[0-9]*) new_version=$1 ;;
*)
  echo "Usage: $0 <patch|minor|major|X.Y.Z>  (current: $current_version)" >&2
  exit 1
  ;;
esac

printf "Release v%s -> v%s? [y/N] " "$current_version" "$new_version"
read -r answer
[ "$answer" = y ] || exit 1

find . -name Dockerfile -not -path './original.bk/*' -exec perl -pi -e "s/\Q$current_version\E/$new_version/g" {} +
git --no-pager diff --stat

git commit -am "release: v$new_version"
git push

git tag "v$new_version" -m "v$new_version" --sign
git push origin "v$new_version"

gh release create "v$new_version" --generate-notes
gh workflow view 'Build & Publish Containers'
gh release view -w
