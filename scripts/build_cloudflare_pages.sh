#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Installing Flutter stable for Cloudflare Pages..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter-sdk
  export PATH="/tmp/flutter-sdk/bin:${PATH}"
fi

flutter config --enable-web
flutter pub get
flutter build web --release --no-wasm-dry-run
cp web/_redirects build/web/_redirects
