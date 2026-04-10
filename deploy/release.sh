#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d%H%M%S)}"

RELEASES_DIR="${RELEASES_DIR:-/var/www/releases/portfolio-hp}"
RELEASE_DIR="$RELEASES_DIR/$TIMESTAMP"
TARGET_ROOT="${TARGET_ROOT:-/var/www/html}"
WORK_DIR="$(mktemp -d)"

INDEX_LINK="${INDEX_LINK:-$TARGET_ROOT/index.html}"
PAGE2_LINK="${PAGE2_LINK:-$TARGET_ROOT/page2.html}"

PREVIOUS_INDEX=""
PREVIOUS_PAGE2=""

rollback() {
  local exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    return
  fi

  echo "release failed, rolling back portfolio links"

  if [[ -n "$PREVIOUS_INDEX" ]]; then
    sudo ln -sfn "$PREVIOUS_INDEX" "$INDEX_LINK"
  fi
  if [[ -n "$PREVIOUS_PAGE2" ]]; then
    sudo ln -sfn "$PREVIOUS_PAGE2" "$PAGE2_LINK"
  fi

  sudo nginx -t || true
  sudo systemctl reload nginx || true
  rm -rf "$WORK_DIR"
  exit "$exit_code"
}
trap rollback EXIT

mkdir -p "$WORK_DIR/$TIMESTAMP"
install -m 644 "$ROOT_DIR/index.html" "$WORK_DIR/$TIMESTAMP/index.html"
install -m 644 "$ROOT_DIR/page2.html" "$WORK_DIR/$TIMESTAMP/page2.html"

[[ -f "$WORK_DIR/$TIMESTAMP/index.html" ]]
[[ -f "$WORK_DIR/$TIMESTAMP/page2.html" ]]

PREVIOUS_INDEX="$(readlink -f "$INDEX_LINK" 2>/dev/null || true)"
PREVIOUS_PAGE2="$(readlink -f "$PAGE2_LINK" 2>/dev/null || true)"

sudo mkdir -p "$RELEASES_DIR"
sudo mv "$WORK_DIR/$TIMESTAMP" "$RELEASE_DIR"
sudo ln -sfn "$RELEASES_DIR/$TIMESTAMP/index.html" "$INDEX_LINK"
sudo ln -sfn "$RELEASES_DIR/$TIMESTAMP/page2.html" "$PAGE2_LINK"
sudo nginx -t
sudo systemctl reload nginx

trap - EXIT
rm -rf "$WORK_DIR"
echo "portfolio release complete: $TIMESTAMP"
