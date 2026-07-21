#!/usr/bin/env bash
set -euo pipefail

flutter build web --release --no-wasm-dry-run
cp web/_redirects build/web/_redirects
