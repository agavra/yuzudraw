#!/bin/sh
set -eu

REPO="agavra/yuzudraw"
RAW_BASE_URL="https://raw.githubusercontent.com/${REPO}/main"
INSTALL_DIR="$HOME/.yuzudraw/bin"
BIN_NAME="yuzudraw-cli"
AGENT_SELECTION=""
SKIP_SKILLS=0

main() {
    parse_args "$@"
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

    if [ "${SKIP_SKILLS}" -ne 1 ]; then
        AGENT_SELECTION=$(resolve_agent_selection)
        install_agent_skills "$AGENT_SELECTION"
    fi

    echo ""
    echo "${BIN_NAME} v${VERSION} installed to ${INSTALL_DIR}/${BIN_NAME}"
    if [ "${SKIP_SKILLS}" -eq 1 ]; then
        echo "Skipped agent skill installation."
    elif [ -n "${AGENT_SELECTION}" ]; then
        echo "Installed YuzuDraw skills for: $(format_agent_list "$AGENT_SELECTION")"
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
Usage: install.sh [--agent codex|claude|both|none] [--skip-skills]

Installs the YuzuDraw CLI and optionally the YuzuDraw skills for Codex and/or Claude.
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
    RELEASE_URL="https://api.github.com/repos/${REPO}/releases/latest"
    TAG=$(curl -fsSL "$RELEASE_URL" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/')
    if [ -z "$TAG" ]; then
        echo "Error: could not determine latest version from GitHub." >&2
        exit 1
    fi
    echo "$TAG"
}

resolve_agent_selection() {
    if [ -n "${AGENT_SELECTION}" ]; then
        printf '%s\n' "$AGENT_SELECTION"
        return
    fi

    if [ -r /dev/tty ]; then
        prompt_agent_selection
        return
    fi

    echo "No interactive terminal detected. Installing skills for both Codex and Claude."
    printf '%s\n' "codex claude"
}

prompt_agent_selection() {
    current=0
    selected_codex=1
    selected_claude=1
    ESC=$(printf '\033')
    old_stty=$(stty -g < /dev/tty)

    cleanup_prompt() {
        printf '\033[?25h' > /dev/tty
        stty "$old_stty" < /dev/tty
        trap - INT TERM
    }

    trap 'cleanup_prompt; printf "\r\n" > /dev/tty; exit 1' INT TERM

    printf '\n  Install YuzuDraw skills for:\n\n' > /dev/tty
    printf '\033[?25l' > /dev/tty
    stty raw -echo < /dev/tty

    draw_prompt() {
        if [ "$current" -eq 0 ]; then
            prefix=$(printf '  \033[36m>\033[0m')
        else
            prefix='   '
        fi
        if [ "$selected_codex" -eq 1 ]; then
            codex_box=$(printf '[\033[33m✓\033[0m]')
        else
            codex_box='[ ]'
        fi
        codex_label=$(printf '\033[34mCodex\033[0m')
        printf '%s %s %s\033[K\r\n' "$prefix" "$codex_box" "$codex_label" > /dev/tty

        if [ "$current" -eq 1 ]; then
            prefix=$(printf '  \033[36m>\033[0m')
        else
            prefix='   '
        fi
        if [ "$selected_claude" -eq 1 ]; then
            claude_box=$(printf '[\033[33m✓\033[0m]')
        else
            claude_box='[ ]'
        fi
        claude_label=$(printf '\033[32mClaude\033[0m')
        printf '%s %s %s\033[K\r\n' "$prefix" "$claude_box" "$claude_label" > /dev/tty
        printf '\033[K\r\n  \033[2mArrow keys to move, Space to toggle, Enter to confirm\033[0m\033[K' > /dev/tty
    }

    draw_prompt

    while true; do
        c=$(dd bs=1 count=1 2>/dev/null < /dev/tty; printf .)
        c=${c%.}

        if [ "$c" = "$(printf '\003')" ]; then
            cleanup_prompt
            printf '\r\n' > /dev/tty
            exit 1
        fi

        if [ "$c" = "$(printf '\r')" ]; then
            if [ "$selected_codex" -eq 0 ] && [ "$selected_claude" -eq 0 ]; then
                selected_codex=1
                selected_claude=1
            fi
            break
        fi

        if [ "$c" = " " ]; then
            if [ "$current" -eq 0 ]; then
                if [ "$selected_codex" -eq 1 ]; then
                    selected_codex=0
                else
                    selected_codex=1
                fi
            else
                if [ "$selected_claude" -eq 1 ]; then
                    selected_claude=0
                else
                    selected_claude=1
                fi
            fi
            printf '\033[3A\r' > /dev/tty
            draw_prompt
            continue
        fi

        if [ "$c" = "$ESC" ]; then
            dd bs=1 count=1 2>/dev/null < /dev/tty > /dev/null 2>&1
            c3=$(dd bs=1 count=1 2>/dev/null < /dev/tty; printf .)
            c3=${c3%.}
            case "$c3" in
                A) [ "$current" -gt 0 ] && current=$((current - 1)) ;;
                B) [ "$current" -lt 1 ] && current=$((current + 1)) ;;
            esac
            printf '\033[3A\r' > /dev/tty
            draw_prompt
        fi
    done

    cleanup_prompt
    printf '\n\n' > /dev/tty

    RESULT=""
    if [ "$selected_codex" -eq 1 ]; then
        RESULT="codex"
    fi
    if [ "$selected_claude" -eq 1 ]; then
        if [ -n "$RESULT" ]; then
            RESULT="${RESULT} claude"
        else
            RESULT="claude"
        fi
    fi

    printf '%s\n' "$RESULT"
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

        install_skill "$TARGET_ROOT" "diagram"
        install_skill "$TARGET_ROOT" "bar-chart"
    done
}

install_skill() {
    TARGET_ROOT=$1
    SKILL_NAME=$2
    TARGET_DIR="${TARGET_ROOT}/${SKILL_NAME}"
    SKILL_URL="${RAW_BASE_URL}/skills/${SKILL_NAME}/SKILL.md"

    echo "Installing ${SKILL_NAME} skill to ${TARGET_DIR}..."
    mkdir -p "$TARGET_DIR"
    curl -fsSL "$SKILL_URL" -o "${TARGET_DIR}/SKILL.md"
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
    echo "# YuzuDraw CLI" >> "$PROFILE"
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$PROFILE"
    echo "Added ${INSTALL_DIR} to PATH in ${PROFILE}. Restart your shell or run:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
}

main "$@"
