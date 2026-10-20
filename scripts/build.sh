#!/usr/bin/env bash
# Usage: scripts/build.sh [apk|appbundle] [major|minor|patch]
# Examples:
#   scripts/build.sh                 -> release APK, version unchanged
#   scripts/build.sh apk minor       -> bump minor, then release APK
#   scripts/build.sh appbundle patch -> bump patch, then release AAB (Play Store)
set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-apk}"
BUMP="${2:-}"

case "$TARGET" in
  apk|appbundle) ;;
  *) echo "Invalid target '$TARGET' (expected: apk or appbundle)"; exit 1 ;;
esac

bash scripts/bump_version.sh "$BUMP"

flutter build "$TARGET" --release