#!/bin/bash
#
# Bumps the package version in pubspec.yaml, adds a matching entry to the top
# of CHANGELOG.md, and prints the git commands to review and commit the bump.
#
# Usage:
#   bin/bump_version.sh <major|minor|patch> "Description of the change"
#   bin/bump_version.sh 1.2.3 "Description of the change"

set -e

cd "$(dirname "$0")/.."

usage() {
    echo "Usage: $0 <major|minor|patch|X.Y.Z> \"Description of the change\"" >&2
    exit 1
}

part=$1
description=$2

if [[ -z "$part" || -z "$description" ]]; then
    usage
fi

current_version=$(grep -E '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//')
if [[ -z "$current_version" ]]; then
    echo "Error: could not find a 'version:' line in pubspec.yaml" >&2
    exit 1
fi

IFS='.' read -r major minor patch <<< "$current_version"

case "$part" in
    major)
        new_version="$((major + 1)).0.0"
        ;;
    minor)
        new_version="$major.$((minor + 1)).0"
        ;;
    patch)
        new_version="$major.$minor.$((patch + 1))"
        ;;
    [0-9]*.[0-9]*.[0-9]*)
        new_version="$part"
        ;;
    *)
        usage
        ;;
esac

echo "Bumping version: $current_version -> $new_version"

sed -i.bak -E "s/^version:[[:space:]]*.*/version: $new_version/" pubspec.yaml
rm pubspec.yaml.bak

changelog_tmp=$(mktemp)
{
    printf '# %s\n\n* %s\n\n' "$new_version" "$description"
    cat CHANGELOG.md
} > "$changelog_tmp"
mv "$changelog_tmp" CHANGELOG.md

echo "Updated pubspec.yaml and CHANGELOG.md."
echo
echo "Review the changes, then commit with:"
echo "  git add pubspec.yaml CHANGELOG.md"
echo "  git commit -m \"v$new_version: $description\""
