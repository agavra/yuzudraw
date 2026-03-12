#!/bin/sh
set -eu

REPO="agavra/yuzudraw"
INSTALL_DIR="$HOME/.yuzudraw/bin"
BIN_NAME="yuzudraw-cli"

main() {
    check_macos
    ARCH=$(detect_arch)
    VERSION=$(fetch_latest_version)
    ASSET_NAME="${BIN_NAME}-${VERSION}-${ARCH}-apple-darwin.tar.gz"
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${ASSET_NAME}"

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    echo "Downloading ${BIN_NAME} v${VERSION} (${ARCH})..."
    curl -fSL --progress-bar "$DOWNLOAD_URL" -o "${TMPDIR}/${ASSET_NAME}"

    echo "Installing to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"
    tar -xzf "${TMPDIR}/${ASSET_NAME}" -C "$TMPDIR"
    mv "${TMPDIR}/${BIN_NAME}" "${INSTALL_DIR}/${BIN_NAME}"
    chmod +x "${INSTALL_DIR}/${BIN_NAME}"

    configure_path

    echo ""
    echo "${BIN_NAME} v${VERSION} installed to ${INSTALL_DIR}/${BIN_NAME}"
    echo ""
    echo "Run '${BIN_NAME} help' to get started."
    echo "Run '${BIN_NAME} update' to update to the latest version."
}

check_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        echo "Error: ${BIN_NAME} is only supported on macOS." >&2
        exit 1
    fi
}

detect_arch() {
    case "$(uname -m)" in
        arm64)  echo "aarch64" ;;
        x86_64) echo "x86_64" ;;
        *)
            echo "Error: unsupported architecture $(uname -m)" >&2
            exit 1
            ;;
    esac
}

fetch_latest_version() {
    RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"
    TAG=$(curl -fsSL "$RELEASE_URL" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/')
    if [ -z "$TAG" ]; then
        echo "Error: could not determine latest version from GitHub." >&2
        exit 1
    fi
    echo "$TAG"
}

configure_path() {
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) return ;;
    esac

    # Check if already on PATH
    if command -v "$BIN_NAME" >/dev/null 2>&1; then
        return
    fi

    SHELL_NAME=$(basename "${SHELL:-/bin/zsh}")
    case "$SHELL_NAME" in
        zsh)  PROFILE="$HOME/.zshrc" ;;
        bash) PROFILE="$HOME/.bash_profile" ;;
        *)    PROFILE="$HOME/.profile" ;;
    esac

    if [ -f "$PROFILE" ] && grep -q "$INSTALL_DIR" "$PROFILE" 2>/dev/null; then
        return
    fi

    echo "" >> "$PROFILE"
    echo "# YuzuDraw CLI" >> "$PROFILE"
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$PROFILE"
    echo "Added ${INSTALL_DIR} to PATH in ${PROFILE}. Restart your shell or run:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
}

main
