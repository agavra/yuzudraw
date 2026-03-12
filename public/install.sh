#!/bin/sh
set -eu

REPO="agavra/yuzudraw"
GITHUB_API_URL="https://api.github.com/repos/${REPO}"
RAW_BASE_URL="https://raw.githubusercontent.com/${REPO}/main"
SKILL_PATH="skills/draw"
INSTALL_DIR="$HOME/.yuzudraw/bin"
BIN_NAME="yuzudraw-cli"
AGENT_SELECTION=""
SKIP_SKILLS=0
UNINSTALL=0
DRAW_SKILL_FILES="SKILL.md references/architecture.md references/ascii-art.md references/bar-chart.md references/components.md references/flow.md"

fail() {
    echo "Error: $*" >&2
    exit 1
}

download_file() {
    URL=$1
    DEST=$2
    DESCRIPTION=$3

    DEST_DIR=$(dirname "$DEST")
    mkdir -p "$DEST_DIR" || fail "could not create directory ${DEST_DIR} for ${DESCRIPTION}."
    curl -fsSL "$URL" -o "$DEST" || fail "could not download ${DESCRIPTION} from ${URL}."
}

download_file_with_progress() {
    URL=$1
    DEST=$2
    DESCRIPTION=$3

    DEST_DIR=$(dirname "$DEST")
    mkdir -p "$DEST_DIR" || fail "could not create directory ${DEST_DIR} for ${DESCRIPTION}."
    curl -fSL --progress-bar "$URL" -o "$DEST" || fail "could not download ${DESCRIPTION} from ${URL}."
}

fetch_url() {
    URL=$1
    DESCRIPTION=$2

    curl -fsSL "$URL" || fail "could not fetch ${DESCRIPTION} from ${URL}."
}

main() {
    parse_args "$@"
    if [ "${UNINSTALL}" -eq 1 ]; then
        uninstall
        exit 0
    fi

    check_macos
    ARCH=$(detect_arch)
    VERSION=$(fetch_latest_version)
    ASSET_NAME="${BIN_NAME}-${VERSION}-${ARCH}-apple-darwin.tar.gz"
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${ASSET_NAME}"

    TMPDIR=$(mktemp -d) || fail "could not create a temporary directory."
    trap 'rm -rf "$TMPDIR"' EXIT

    echo "Downloading ${BIN_NAME} v${VERSION} (${ARCH})..."
    download_file_with_progress "$DOWNLOAD_URL" "${TMPDIR}/${ASSET_NAME}" "${BIN_NAME} v${VERSION} (${ARCH})"

    echo "Installing to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR" || fail "could not create install directory ${INSTALL_DIR}."
    tar -xzf "${TMPDIR}/${ASSET_NAME}" -C "$TMPDIR" || fail "could not extract ${ASSET_NAME}."
    [ -f "${TMPDIR}/${BIN_NAME}" ] || fail "archive ${ASSET_NAME} did not contain ${BIN_NAME}."
    mv "${TMPDIR}/${BIN_NAME}" "${INSTALL_DIR}/${BIN_NAME}" || fail "could not move ${BIN_NAME} into ${INSTALL_DIR}."
    chmod +x "${INSTALL_DIR}/${BIN_NAME}" || fail "could not mark ${INSTALL_DIR}/${BIN_NAME} as executable."

    configure_path

    if [ "${SKIP_SKILLS}" -ne 1 ]; then
        AGENT_SELECTION=$(resolve_agent_selection)
        install_agent_skills "$AGENT_SELECTION"
    fi

    echo ""
    echo "${BIN_NAME} v${VERSION} installed to ${INSTALL_DIR}/${BIN_NAME}"
    if [ "${SKIP_SKILLS}" -eq 1 ]; then
        echo "Skipped agent skill installation."
    elif [ -n "${AGENT_SELECTION}" ]; then
        echo "Installed the YuzuDraw draw skill for: $(format_agent_list "$AGENT_SELECTION")"
    else
        echo "Skipped agent skill installation."
    fi
    echo ""
    echo "Run '${BIN_NAME} help' to get started."
    echo "Run '${BIN_NAME} update' to update to the latest version."
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --agent=*)
                AGENT_SELECTION=$(normalize_agent_selection "${1#*=}")
                ;;
            --agent)
                shift
                if [ "$#" -eq 0 ]; then
                    echo "Error: --agent requires a value." >&2
                    exit 1
                fi
                AGENT_SELECTION=$(normalize_agent_selection "$1")
                ;;
            --skip-skills)
                SKIP_SKILLS=1
                ;;
            --uninstall)
                UNINSTALL=1
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                echo "Error: unknown argument '$1'." >&2
                print_help >&2
                exit 1
                ;;
        esac
        shift
    done
}

print_help() {
    cat <<EOF
Usage: install.sh [--agent codex|claude|both|none] [--skip-skills] [--uninstall]

Installs the YuzuDraw CLI and optionally the YuzuDraw draw skill for Codex and/or Claude.
Use --uninstall to remove the CLI, the draw skill, and the PATH entry added by this installer.
EOF
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
    RELEASE_URL="${GITHUB_API_URL}/releases/latest"
    TAG=$(fetch_url "$RELEASE_URL" "latest release metadata" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/')
    if [ -z "$TAG" ]; then
        fail "could not determine the latest version from ${RELEASE_URL}."
    fi
    echo "$TAG"
}

resolve_agent_selection() {
    if [ -n "${AGENT_SELECTION}" ]; then
        printf '%s\n' "$AGENT_SELECTION"
        return
    fi

    DETECTED_AGENTS=$(detect_installed_agents)
    if [ -n "$DETECTED_AGENTS" ]; then
        echo "Detected agent homes for: $(format_agent_list "$DETECTED_AGENTS")" >&2
        printf '%s\n' "$DETECTED_AGENTS"
        return
    fi

    if [ -r /dev/tty ]; then
        prompt_agent_selection
        return
    fi

    echo "No supported agent home detected. Installed CLI only." >&2
    echo "To install the draw skill later, rerun with --agent codex or --agent claude." >&2
    printf '\n'
}

detect_installed_agents() {
    RESULT=""

    if [ -d "${CODEX_HOME:-$HOME/.codex}" ] || [ -f "$HOME/.codex/config.toml" ]; then
        RESULT="codex"
    fi

    if [ -d "$HOME/.claude" ]; then
        if [ -n "$RESULT" ]; then
            RESULT="${RESULT} claude"
        else
            RESULT="claude"
        fi
    fi

    printf '%s\n' "$RESULT"
}

prompt_agent_selection() {
    printf '\nInstall the YuzuDraw draw skill for:\n' > /dev/tty
    printf '  1) Codex\n' > /dev/tty
    printf '  2) Claude\n' > /dev/tty
    printf '  3) Both\n' > /dev/tty
    printf '  4) Skip skill installation\n' > /dev/tty
    printf 'Selection [3]: ' > /dev/tty

    if ! IFS= read -r SELECTION < /dev/tty; then
        printf '\n'
        return
    fi

    if [ -z "$SELECTION" ]; then
        SELECTION="3"
    fi

    normalize_agent_selection "$SELECTION"
}

normalize_agent_selection() {
    RAW_SELECTION=$1

    if [ -z "$RAW_SELECTION" ]; then
        RAW_SELECTION="both"
    fi

    OLD_IFS=$IFS
    IFS=', '
    set -- $RAW_SELECTION
    IFS=$OLD_IFS

    INSTALL_CODEX=0
    INSTALL_CLAUDE=0
    INSTALL_NONE=0

    for ITEM in "$@"; do
        LOWER_ITEM=$(printf '%s' "$ITEM" | tr '[:upper:]' '[:lower:]')
        case "$LOWER_ITEM" in
            1|codex)
                INSTALL_CODEX=1
                ;;
            2|claude)
                INSTALL_CLAUDE=1
                ;;
            3|both|all)
                INSTALL_CODEX=1
                INSTALL_CLAUDE=1
                ;;
            4|none|skip|cli|cli-only)
                INSTALL_NONE=1
                ;;
            "")
                ;;
            *)
                echo "Error: unsupported agent selection '$ITEM'." >&2
                exit 1
                ;;
        esac
    done

    if [ "$INSTALL_NONE" -eq 1 ] && { [ "$INSTALL_CODEX" -eq 1 ] || [ "$INSTALL_CLAUDE" -eq 1 ]; }; then
        echo "Error: choose either CLI only or one or more agents." >&2
        exit 1
    fi

    if [ "$INSTALL_NONE" -eq 1 ]; then
        printf '\n'
        return
    fi

    RESULT=""
    if [ "$INSTALL_CODEX" -eq 1 ]; then
        RESULT="codex"
    fi
    if [ "$INSTALL_CLAUDE" -eq 1 ]; then
        if [ -n "$RESULT" ]; then
            RESULT="${RESULT} claude"
        else
            RESULT="claude"
        fi
    fi

    if [ -z "$RESULT" ]; then
        echo "Error: no agents selected." >&2
        exit 1
    fi

    printf '%s\n' "$RESULT"
}

install_agent_skills() {
    AGENTS=$1

    if [ -z "$AGENTS" ]; then
        return
    fi

    for AGENT in $AGENTS; do
        case "$AGENT" in
            codex)
                TARGET_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
                ;;
            claude)
                TARGET_ROOT="$HOME/.claude/skills"
                ;;
            *)
                echo "Error: unsupported agent '$AGENT'." >&2
                exit 1
                ;;
        esac

        install_draw_skill "$TARGET_ROOT"
    done
}

install_draw_skill() {
    TARGET_ROOT=$1
    TARGET_DIR="${TARGET_ROOT}/draw"

    echo "Installing draw skill to ${TARGET_DIR}..."
    mkdir -p "$TARGET_DIR" || fail "could not create skill directory ${TARGET_DIR}."

    FILE_COUNT=$(printf '%s\n' "$DRAW_SKILL_FILES" | wc -w | tr -d ' ')
    echo "Found ${FILE_COUNT} draw skill file(s) in ${REPO}/${SKILL_PATH}."

    for SKILL_FILE in $DRAW_SKILL_FILES; do
        [ -n "$SKILL_FILE" ] || continue

        echo "  - ${SKILL_FILE}"
        download_file "${RAW_BASE_URL}/${SKILL_PATH}/${SKILL_FILE}" "${TARGET_DIR}/${SKILL_FILE}" "draw skill file ${SKILL_FILE}"
    done
}

uninstall() {
    echo "Removing ${BIN_NAME}..."
    remove_cli
    remove_agent_skill "${CODEX_HOME:-$HOME/.codex}/skills"
    remove_agent_skill "$HOME/.claude/skills"
    remove_path_entry

    echo ""
    echo "YuzuDraw CLI and draw skill uninstalled."
}

remove_cli() {
    CLI_PATH="${INSTALL_DIR}/${BIN_NAME}"

    if [ -f "$CLI_PATH" ]; then
        rm -f "$CLI_PATH"
        echo "Removed ${CLI_PATH}"
    else
        echo "CLI not found at ${CLI_PATH}"
    fi

    if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
        rmdir "$INSTALL_DIR" 2>/dev/null || true
    fi
}

remove_agent_skill() {
    TARGET_ROOT=$1
    TARGET_DIR="${TARGET_ROOT}/draw"

    if [ -d "$TARGET_DIR" ]; then
        rm -rf "$TARGET_DIR"
        echo "Removed ${TARGET_DIR}"
    fi

    if [ -d "$TARGET_ROOT" ] && [ -z "$(ls -A "$TARGET_ROOT" 2>/dev/null)" ]; then
        rmdir "$TARGET_ROOT" 2>/dev/null || true
    fi
}

remove_path_entry() {
    SHELL_NAME=$(basename "${SHELL:-/bin/zsh}")
    case "$SHELL_NAME" in
        zsh)  PROFILE="$HOME/.zshrc" ;;
        bash) PROFILE="$HOME/.bash_profile" ;;
        *)    PROFILE="$HOME/.profile" ;;
    esac

    if [ ! -f "$PROFILE" ]; then
        return
    fi

    TMP_PROFILE=$(mktemp)
    awk -v install_dir="$INSTALL_DIR" '
        $0 == "# YuzuDraw CLI" { skip_next = 1; changed = 1; next }
        skip_next && $0 == "export PATH=\"" install_dir ":$PATH\"" { skip_next = 0; next }
        skip_next { skip_next = 0 }
        { print }
        END { if (changed) exit 0; exit 0 }
    ' "$PROFILE" > "$TMP_PROFILE"
    mv "$TMP_PROFILE" "$PROFILE"
}

format_agent_list() {
    AGENTS=$1
    PRETTY=""

    for AGENT in $AGENTS; do
        case "$AGENT" in
            codex)
                LABEL="Codex"
                ;;
            claude)
                LABEL="Claude"
                ;;
            *)
                LABEL="$AGENT"
                ;;
        esac

        if [ -n "$PRETTY" ]; then
            PRETTY="${PRETTY}, ${LABEL}"
        else
            PRETTY="$LABEL"
        fi
    done

    printf '%s\n' "$PRETTY"
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
    echo "# YuzuDraw CLI" >> "$PROFILE" || fail "could not update PATH in ${PROFILE}."
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$PROFILE" || fail "could not update PATH in ${PROFILE}."
    echo "Added ${INSTALL_DIR} to PATH in ${PROFILE}. Restart your shell or run:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
}

main "$@"
