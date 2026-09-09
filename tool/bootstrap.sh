#!/usr/bin/env bash
# POSIX equivalent of tool/bootstrap.ps1. See that file for the commentary.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found on PATH." >&2
  exit 1
fi

flutter --version
flutter create . \
  --project-name lettuce_travel \
  --org com.lettucetravel \
  --platforms android,ios \
  --overwrite

flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze

echo
echo "Done. See docs/firebase-setup.md for the Firebase and Maps setup."
