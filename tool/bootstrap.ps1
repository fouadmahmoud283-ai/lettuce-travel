# Generates the native platform folders for Lettuce Travel.
#
# `flutter create` is additive: it fills in android/ and ios/ without touching
# lib/, pubspec.yaml or anything else already in the repo. Run it once after
# installing the Flutter SDK, and again if a platform folder is ever lost.
#
#   pwsh tool/bootstrap.ps1

$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter SDK not found on PATH. Install it from https://docs.flutter.dev/get-started/install/windows and reopen the shell."
}

Write-Host "== Flutter version ==" -ForegroundColor Cyan
flutter --version

Write-Host "== Generating android/ and ios/ ==" -ForegroundColor Cyan
flutter create . `
    --project-name lettuce_travel `
    --org com.lettucetravel `
    --platforms android,ios `
    --overwrite

Write-Host "== Installing packages ==" -ForegroundColor Cyan
flutter pub get

Write-Host "== Generating localizations ==" -ForegroundColor Cyan
flutter gen-l10n

Write-Host "== Running code generation ==" -ForegroundColor Cyan
dart run build_runner build --delete-conflicting-outputs

Write-Host "== Analyzing ==" -ForegroundColor Cyan
flutter analyze

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Green
Write-Host "  1. Create the Firebase project    -> docs/firebase-setup.md"
Write-Host "  2. flutterfire configure --project=lettuce-travel-dev --platforms=android,ios --out=lib/core/config/firebase_options.dart"
Write-Host "  3. Add the Google Maps API keys   -> docs/firebase-setup.md section 5"
Write-Host "  4. Add the location and notification permissions -> section 6"
Write-Host "  5. Uncomment the Firebase init block in lib/bootstrap.dart"
