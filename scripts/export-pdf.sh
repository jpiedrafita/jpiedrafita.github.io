#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/dist"
PDF_PATH="$OUT_DIR/jorge-piedrafita-cv.pdf"
LOG_PATH="${TMPDIR:-/tmp}/jpiedrafita-cv-http.log"

mkdir -p "$OUT_DIR"

if [ -z "${CHROME_BIN:-}" ]; then
	for candidate in \
		"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
		"/Applications/Chromium.app/Contents/MacOS/Chromium" \
		"/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
		"google-chrome" \
		"chromium" \
		"chromium-browser" \
		"microsoft-edge"; do
		if command -v "$candidate" >/dev/null 2>&1; then
			CHROME_BIN="$candidate"
			break
		fi

		if [ -x "$candidate" ]; then
			CHROME_BIN="$candidate"
			break
		fi
	done
fi

if [ -z "${CHROME_BIN:-}" ]; then
	echo "Chrome, Chromium, or Microsoft Edge was not found."
	echo "Fallback: run python3 -m http.server 8000, open http://localhost:8000/, then use Print > Save as PDF."
	exit 1
fi

PORT="${PORT:-$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')}"

cd "$ROOT_DIR"
python3 -m http.server "$PORT" --bind 127.0.0.1 >"$LOG_PATH" 2>&1 &
SERVER_PID=$!

cleanup() {
	kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

sleep 1

if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
	echo "Failed to start local preview server. Log:"
	cat "$LOG_PATH"
	exit 1
fi

"$CHROME_BIN" \
	--headless \
	--disable-gpu \
	--no-sandbox \
	--run-all-compositor-stages-before-draw \
	--virtual-time-budget=1000 \
	--print-to-pdf="$PDF_PATH" \
	--no-pdf-header-footer \
	--print-to-pdf-no-header \
	"http://127.0.0.1:$PORT/"

echo "Wrote $PDF_PATH"
