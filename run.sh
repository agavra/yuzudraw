#!/usr/bin/env bash
set -euo pipefail

APP_NAME="YuzuDraw.app"
DERIVED_DATA_DIR="${HOME}/Library/Developer/Xcode/DerivedData"

if [[ ! -d "${DERIVED_DATA_DIR}" ]]; then
  echo "DerivedData directory not found: ${DERIVED_DATA_DIR}" >&2
  exit 1
fi

LATEST_APP_PATH="$(
  find "${DERIVED_DATA_DIR}" -type d -path "*/Build/Products/*/${APP_NAME}" -print 2>/dev/null \
    | while IFS= read -r app; do
        executable="${app}/Contents/MacOS/YuzuDraw"
        if [[ -x "${executable}" ]]; then
          printf '%s\t%s\n' "$(stat -f '%m' "${app}")" "${app}"
        fi
      done \
    | sort -nr \
    | head -n 1 \
    | cut -f2-
)"

if [[ -z "${LATEST_APP_PATH}" ]]; then
  echo "No runnable ${APP_NAME} found in DerivedData." >&2
  echo "Build once with: xcodebuild -project YuzuDraw.xcodeproj -scheme YuzuDraw -configuration Debug build" >&2
  exit 1
fi

EXECUTABLE="${LATEST_APP_PATH}/Contents/MacOS/YuzuDraw"
echo "Launching: ${EXECUTABLE}"
exec "${EXECUTABLE}" "$@"
