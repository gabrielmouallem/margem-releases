#!/bin/sh
# Installs Margem on this Mac: downloads it, checks it, puts it in Applications and opens it (since 0.26).
# The landing page shows it as one line:   curl -fsSL <where this file lives> | sh
#
# Why a Terminal line: Margem is not notarized by Apple (no paid developer account). A browser marks every download as
# "from the internet", and the Mac then stops an app it cannot check. A download made by curl carries no such mark, so
# the app opens like one you built yourself. This script does nothing else: no root, no other files, no settings.
#
# Options (environment):  MARGEM_ZIP=<url or path>  MARGEM_DEST=<folder>  MARGEM_NO_OPEN=1 (the tests)
set -eu

ZIP_URL="${MARGEM_ZIP:-https://github.com/gabrielmouallem/margem-releases/releases/download/v0.29/Margem.zip}"
SHA256="87f8811d875657d429b8e2a3edfc527f6cf2c88339bf4c5871ba495268417b5f"
VERSION="0.29"

say() { printf '%s\n' "$*"; }
fail() { printf 'Margem: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "Margem runs on a Mac."
[ "$(uname -m)" = "arm64" ] || fail "Margem needs a Mac with Apple silicon."
major="$(sw_vers -productVersion | cut -d. -f1)"
[ "$major" -ge 14 ] 2>/dev/null || fail "Margem needs macOS 14 or later (this Mac has $(sw_vers -productVersion))."

dest="${MARGEM_DEST:-/Applications}"
if [ ! -w "$dest" ]; then
  dest="$HOME/Applications"
  mkdir -p "$dest"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

say "Downloading Margem ${VERSION}..."
case "$ZIP_URL" in
  http*) curl -fL --progress-bar "$ZIP_URL" -o "$tmp/Margem.zip" || fail "the download failed. Try again, or get the app from the page." ;;
  *) cp "$ZIP_URL" "$tmp/Margem.zip" ;;
esac

case "$SHA256" in
  __*) ;;  # a copy of the script with no checksum written in (the tests)
  *)
    got="$(shasum -a 256 "$tmp/Margem.zip" | cut -d' ' -f1)"
    [ "$got" = "$SHA256" ] || fail "the download does not match this version (checksum $got). Nothing was installed."
    ;;
esac

ditto -x -k "$tmp/Margem.zip" "$tmp/unzipped" || fail "the download is not a valid app archive."
[ -d "$tmp/unzipped/Margem.app" ] || fail "the archive has no Margem.app."
codesign --verify --deep --strict "$tmp/unzipped/Margem.app" 2>/dev/null || fail "the app's signature does not check. Nothing was installed."

# The Margem being replaced quits first, if it is open (only that copy: a Margem elsewhere keeps running).
if pgrep -f "$dest/Margem.app/Contents/MacOS/Margem" >/dev/null 2>&1; then
  osascript -e 'tell application "Margem" to quit' >/dev/null 2>&1 || true
  sleep 1
fi
rm -rf "$dest/Margem.app"
ditto "$tmp/unzipped/Margem.app" "$dest/Margem.app"
# The mark only exists if the archive came from a browser and was passed in by hand; take it off this app only.
xattr -dr com.apple.quarantine "$dest/Margem.app" 2>/dev/null || true

say "Margem is in $dest."
if [ -z "${MARGEM_NO_OPEN:-}" ]; then
  open "$dest/Margem.app"
  say "It lives in the menu bar (the speech bubble). The welcome window asks for one permission, Accessibility."
fi
