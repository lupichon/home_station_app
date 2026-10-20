#!/usr/bin/env bash
# Usage: scripts/run.sh <device_id> [debug|profile|release]
# Examples:
#   scripts/run.sh ANCTUT4108000668
#   scripts/run.sh ANCTUT4108000668 release
set -euo pipefail
cd "$(dirname "$0")/.."

DEVICE="${1:-}"
MODE="${2:-debug}"

if [[ -z "$DEVICE" ]]; then
  echo "Usage: $0 <device_id> [debug|profile|release]"
  echo
  flutter devices
  exit 1
fi

case "$MODE" in
  debug|profile|release) ;;
  *) echo "Invalid mode '$MODE' (expected: debug, profile or release)"; exit 1 ;;
esac

# No bump: only keeps lib/utils/app_version.dart in sync with pubspec.yaml
bash scripts/bump_version.sh

echo "[run] device=$DEVICE mode=$MODE"
flutter run -d "$DEVICE" "--$MODE"