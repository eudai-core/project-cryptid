#!/usr/bin/env bash
# Stamp ReplicatedStorage.BuildSha in default.project.json before rojo build.
# Usage:
#   scripts/stamp-build.sh [sha]
# A GitHub zip has no .git directory, so pass the commit from the archive name.
# With no argument, BUILD_SHA is used, then `git rev-parse HEAD`, then "dev".
# An invalid sha exits 1 and does not write.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
file="default.project.json"

sha="${1:-}"
if [[ -z "$sha" && -n "${BUILD_SHA:-}" ]]; then
	sha="$BUILD_SHA"
fi
if [[ -z "$sha" ]]; then
	if git rev-parse --verify HEAD >/dev/null 2>&1; then
		sha="$(git rev-parse HEAD)"
	else
		sha="dev"
		echo "stamp-build: no git commit; BuildSha=dev" >&2
	fi
fi

sha="$(printf '%s' "$sha" | tr '[:upper:]' '[:lower:]')"
if [[ "$sha" != "dev" && ! "$sha" =~ ^[0-9a-f]{7,40}$ ]]; then
	echo "stamp-build: sha must be 'dev' or 7-40 hex characters" >&2
	exit 1
fi

if ! grep -q '"BuildSha"' "$file"; then
	echo "stamp-build: $file has no BuildSha attribute" >&2
	exit 1
fi

tmp="$(mktemp)"
sed -E "s/(\"BuildSha\"[[:space:]]*:[[:space:]]*\")[^\"]*\"/\\1${sha}\"/" "$file" > "$tmp"
mv "$tmp" "$file"
echo "stamp-build: BuildSha=${sha}"
