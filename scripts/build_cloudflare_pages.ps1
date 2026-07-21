flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Copy-Item -LiteralPath web\_redirects -Destination build\web\_redirects -Force
