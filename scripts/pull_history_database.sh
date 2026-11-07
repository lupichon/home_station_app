#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="com.example.home_station_app"
DATABASE_NAME="home_station_history.db"
OUTPUT_DIR="$PROJECT_ROOT/database"
OUTPUT_FILE="$OUTPUT_DIR/$DATABASE_NAME"
TEMP_FILE="$OUTPUT_FILE.tmp"
DEVICE_SERIAL="${1:-}"
ADB_ARGS=()

if [[ -n "$DEVICE_SERIAL" ]]; then
  ADB_ARGS=(-s "$DEVICE_SERIAL")
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "Erreur : adb est introuvable. Installe Android Platform Tools ou ajoute adb au PATH." >&2
  exit 1
fi

if ! adb "${ADB_ARGS[@]}" get-state >/dev/null 2>&1; then
  echo "Erreur : aucun appareil Android accessible via adb." >&2
  adb devices -l >&2 || true
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
trap 'rm -f "$TEMP_FILE"' EXIT

if ! adb "${ADB_ARGS[@]}" exec-out run-as "$PACKAGE" cat "databases/$DATABASE_NAME" >"$TEMP_FILE"; then
  echo "Erreur : impossible de lire la base. Vérifie que l'application est installée et débogable." >&2
  exit 1
fi

if [[ ! -s "$TEMP_FILE" ]] || [[ "$(head -c 15 "$TEMP_FILE")" != "SQLite format 3" ]]; then
  echo "Erreur : le fichier récupéré est vide ou n'est pas une base SQLite valide." >&2
  exit 1
fi

mv "$TEMP_FILE" "$OUTPUT_FILE"
echo "Base récupérée : $OUTPUT_FILE"