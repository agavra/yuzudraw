#!/usr/bin/env bash
set -euo pipefail

# Build YuzuDraw.app, sign, notarize, and package into a DMG.
# Usage: ./scripts/build-dmg.sh [--arch universal|arm64|x86_64] [--no-sign]
#
# Requirements: Xcode CLI tools, xcodegen, hdiutil (ships with macOS)
#
# For signing/notarization, set these environment variables:
#   APPLE_TEAM_ID          — 10-char team ID
#   APPLE_ID               — Apple ID email
#   APPLE_APP_PASSWORD     — app-specific password for notarization
#   CODE_SIGN_IDENTITY     — signing identity (default: "Developer ID Application: Almog Gavra ($APPLE_TEAM_ID)")

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/YuzuDraw.xcarchive"
APP_NAME="YuzuDraw"
DMG_DIR="$BUILD_DIR/dmg"

# Defaults
ARCH="universal"
SIGN=true

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --arch) ARCH="$2"; shift 2 ;;
    --no-sign) SIGN=false; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Signing variables (only required when signing)
if $SIGN; then
  APPLE_TEAM_ID="${APPLE_TEAM_ID:?Set APPLE_TEAM_ID environment variable}"
  APPLE_ID="${APPLE_ID:?Set APPLE_ID environment variable}"
  CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:-Developer ID Application: Almog Gavra (${APPLE_TEAM_ID})}"
fi

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

if $SIGN; then
  echo "==> Building $APP_NAME ($ARCH_LABEL) with signing"
  xcodebuild archive \
    -scheme "$APP_NAME" \
    -destination 'generic/platform=macOS' \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    ARCHS="$ARCHS" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
    CODE_SIGN_STYLE=Manual \
    2>&1 | tail -20
else
  echo "==> Building $APP_NAME ($ARCH_LABEL) without signing"
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
fi

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

if $SIGN; then
  echo "==> Signing DMG"
  codesign --force --sign "$CODE_SIGN_IDENTITY" "$DMG_PATH"

  if [[ -n "${APPLE_APP_PASSWORD:-}" ]]; then
    echo "==> Submitting for notarization"
    xcrun notarytool submit "$DMG_PATH" \
      --apple-id "$APPLE_ID" \
      --team-id "$APPLE_TEAM_ID" \
      --password "$APPLE_APP_PASSWORD" \
      --wait

    echo "==> Stapling notarization ticket"
    xcrun stapler staple "$DMG_PATH"
  else
    echo "==> Skipping notarization (APPLE_APP_PASSWORD not set)"
  fi
fi

echo ""
echo "==> Done! DMG created at:"
echo "    $DMG_PATH"
echo ""
echo "    Size: $(du -h "$DMG_PATH" | cut -f1)"
echo "    SHA-256: $(shasum -a 256 "$DMG_PATH" | cut -d' ' -f1)"
if $SIGN; then
  echo "    Signed: yes"
  echo "    Notarized: ${APPLE_APP_PASSWORD:+yes}${APPLE_APP_PASSWORD:-no (APPLE_APP_PASSWORD not set)}"
fi
