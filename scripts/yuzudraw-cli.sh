#!/usr/bin/env bash
set -euo pipefail

BIN_NAME="YuzuDrawCLI"
DERIVED_DATA_DIR="${HOME}/Library/Developer/Xcode/DerivedData"

latest_binary_path() {
  find "${DERIVED_DATA_DIR}" -type f -path "*/Build/Products/*/${BIN_NAME}" -print 2>/dev/null \
    | while IFS= read -r bin; do
        if [[ -x "${bin}" ]]; then
          printf '%s\t%s\n' "$(stat -f '%m' "${bin}")" "${bin}"
        fi
      done \
    | sort -nr \
    | head -n 1 \
    | cut -f2-
}

if [[ ! -d "${DERIVED_DATA_DIR}" ]]; then
  echo "DerivedData directory not found: ${DERIVED_DATA_DIR}" >&2
  exit 1
fi

BIN_PATH="$(latest_binary_path)"

if [[ -z "${BIN_PATH}" ]]; then
  echo "YuzuDrawCLI is not built yet. Building..." >&2
  xcodebuild -project YuzuDraw.xcodeproj -scheme YuzuDrawCLI -configuration Debug build >/dev/null
  BIN_PATH="$(latest_binary_path)"
fi

if [[ -z "${BIN_PATH}" ]]; then
  echo "Failed to locate built ${BIN_NAME} binary." >&2
  exit 1
fi

"${BIN_PATH}" "$@"
