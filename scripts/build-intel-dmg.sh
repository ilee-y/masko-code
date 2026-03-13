#!/bin/bash
# Build x86_64 app bundle and package DMG
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Masko Code"
BUNDLE_NAME="${APP_NAME}.app"
ARCH="x86_64"
CONFIG="release"

BUILD_DIR="$ROOT_DIR/.build"
BIN_PATH="$BUILD_DIR/${ARCH}-apple-macosx/${CONFIG}/masko-code"
DIST_DIR="$ROOT_DIR/build/intel"
APP_DIR="$DIST_DIR/$BUNDLE_NAME"
DMG_PATH="$DIST_DIR/masko-code-intel.dmg"

rm -rf "$APP_DIR" "$DMG_PATH"

swift build --configuration "$CONFIG" --arch "$ARCH"

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$APP_DIR/Contents/Frameworks"
cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/masko-code"
cp "$ROOT_DIR/Info.plist" "$APP_DIR/Contents/Info.plist"
cp -R "$ROOT_DIR/Sources/Resources/"* "$APP_DIR/Contents/Resources/"
cp -R "$BUILD_DIR/${ARCH}-apple-macosx/${CONFIG}/Sparkle.framework" "$APP_DIR/Contents/Frameworks/"

install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_DIR/Contents/MacOS/masko-code"

"$ROOT_DIR/scripts/create-dmg.sh" \
  "$APP_DIR" \
  "$DMG_PATH" \
  "$APP_NAME" \
  "$ROOT_DIR/scripts/dmg-background.py"

echo "Intel DMG ready: $DMG_PATH"
