#!/usr/bin/env bash
# Usage: scripts/bump_version.sh [major|minor|patch]
#   (no argument) -> version unchanged, only regenerates app_version.dart
#   patch         -> 1.2.3+4 -> 1.2.4+5
#   minor         -> 1.2.3+4 -> 1.3.0+5
#   major         -> 1.2.3+4 -> 2.0.0+5
set -euo pipefail
cd "$(dirname "$0")/.."

PUBSPEC="pubspec.yaml"
DART_FILE="lib/utils/app_version.dart"
BUMP="${1:-}"

case "$BUMP" in
  ""|major|minor|patch) ;;
  *) echo "Invalid bump '$BUMP' (expected: major, minor or patch)"; exit 1 ;;
esac

# ── Read the current version from pubspec.yaml ──
current=$(grep -E '^version:' "$PUBSPEC" | head -n1 | sed -E 's/^version:[[:space:]]*//' | tr -d '\r')
if [[ -z "$current" ]]; then
  echo "No 'version:' line found in $PUBSPEC"; exit 1
fi

name="${current%%+*}"
build=0
[[ "$current" == *+* ]] && build="${current##*+}"
IFS='.' read -r major minor patch <<< "$name"

# ── Apply the bump ──
case "$BUMP" in
  major) major=$((major + 1)); minor=0; patch=0; build=$((build + 1)) ;;
  minor) minor=$((minor + 1)); patch=0;          build=$((build + 1)) ;;
  patch) patch=$((patch + 1));                   build=$((build + 1)) ;;
esac

new_name="$major.$minor.$patch"
new_full="$new_name+$build"

# ── Write pubspec.yaml (portable: no sed -i) ──
sed -E "s/^version:.*/version: $new_full/" "$PUBSPEC" > "$PUBSPEC.tmp" && mv "$PUBSPEC.tmp" "$PUBSPEC"

# ── Generate the Dart constants ──
mkdir -p "$(dirname "$DART_FILE")"
cat > "$DART_FILE" <<EOF
// app_version.dart
// Auto-managed by scripts/bump_version.sh. Do not edit by hand.

const String appVersionName   = '$new_name';
const int    appBuildNumber   = $build;
const String appVersionString = '$new_full';
EOF

if [[ -n "$BUMP" ]]; then
  echo "[bump_version] Bumped ($BUMP) -> $new_full"
else
  echo "[bump_version] Version unchanged: $new_full"
fi