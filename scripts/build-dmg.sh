#!/usr/bin/env bash
set -euo pipefail

# Build YuzuDraw.app and package it into a DMG for distribution.
# Usage: ./scripts/build-dmg.sh [--arch universal|arm64|x86_64]
#
# Requirements: Xcode CLI tools, xcodegen, hdiutil (ships with macOS)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/YuzuDraw.xcarchive"
APP_NAME="YuzuDraw"
DMG_DIR="$BUILD_DIR/dmg"

# Parse arguments
ARCH="universal"
while [[ $# -gt 0 ]]; do
  case $1 in
    --arch) ARCH="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Determine architecture flags
case "$ARCH" in
  universal)  ARCHS="arm64 x86_64"; ARCH_LABEL="universal" ;;
  arm64)      ARCHS="arm64";         ARCH_LABEL="arm64" ;;
  x86_64)     ARCHS="x86_64";        ARCH_LABEL="x86_64" ;;
  *) echo "Invalid arch: $ARCH (use universal, arm64, or x86_64)"; exit 1 ;;
esac

echo "==> Cleaning build directory"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Generating Xcode project"
cd "$PROJECT_DIR"
xcodegen generate

echo "==> Building $APP_NAME ($ARCH_LABEL)"
xcodebuild archive \
  -scheme "$APP_NAME" \
  -destination 'generic/platform=macOS' \
  -archivePath "$ARCHIVE_PATH" \
  -configuration Release \
  ARCHS="$ARCHS" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tail -20

# Extract the .app from the archive
APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_NAME.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: $APP_PATH not found in archive"
  exit 1
fi

echo "==> Preparing DMG contents"
mkdir -p "$DMG_DIR"
cp -R "$APP_PATH" "$DMG_DIR/"

# Create a symlink to /Applications for drag-to-install
ln -s /Applications "$DMG_DIR/Applications"

# Get version from Info.plist
VERSION=$(defaults read "$APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0")
DMG_NAME="${APP_NAME}-${VERSION}-${ARCH_LABEL}.dmg"
DMG_PATH="$BUILD_DIR/$DMG_NAME"

echo "==> Creating DMG: $DMG_NAME"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo ""
echo "==> Done! DMG created at:"
echo "    $DMG_PATH"
echo ""
echo "    Size: $(du -h "$DMG_PATH" | cut -f1)"
echo "    SHA-256: $(shasum -a 256 "$DMG_PATH" | cut -d' ' -f1)"
