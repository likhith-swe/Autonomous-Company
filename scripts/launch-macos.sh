#!/usr/bin/env bash
# ============================================================
# Autonomous Company — macOS One-Click Launcher
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "============================================================"
echo "   Autonomous Company — macOS Autonomous Business Engine    "
echo "============================================================"

# Load local environment overrides if present
if [ -f "$ROOT_DIR/.auto-loop.env" ]; then
    echo "→ Loading configuration from .auto-loop.env..."
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.auto-loop.env"
fi

# Detect available engines
HAS_CLAUDE=0
if command -v claude >/dev/null 2>&1 || [ -f "/Users/likhith/.npm-global/bin/claude" ]; then
    HAS_CLAUDE=1
    export PATH="/Users/likhith/.npm-global/bin:$PATH"
fi

# Determine engine choice
SELECTED_ENGINE="${ENGINE:-}"
if [ -z "$SELECTED_ENGINE" ]; then
    if [ "$HAS_CLAUDE" -eq 1 ] && [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        SELECTED_ENGINE="claude"
    elif [ -n "${OPENAI_COMPATIBLE_ENDPOINT:-}" ] || [ -n "${OPENROUTER_API_KEY:-}" ] || [ -n "${DEEPSEEK_API_KEY:-}" ]; then
        SELECTED_ENGINE="openai-compatible"
    elif [ "$HAS_CLAUDE" -eq 1 ]; then
        SELECTED_ENGINE="claude"
    else
        SELECTED_ENGINE="openai-compatible"
    fi
fi

echo "→ Selected Engine: $SELECTED_ENGINE"

if [ "$SELECTED_ENGINE" = "claude" ]; then
    echo "→ Using Claude Code CLI ($(claude --version 2>/dev/null || echo 'installed'))"
    export ENGINE="claude"
    export CLAUDE_PERMISSION_MODE="${CLAUDE_PERMISSION_MODE:-bypassPermissions}"
elif [ "$SELECTED_ENGINE" = "openai-compatible" ]; then
    export ENGINE="openai-compatible"
    export OPENAI_COMPATIBLE_ADAPTER_ENABLED=1
    export OPENAI_COMPATIBLE_ALLOW_SHELL="${OPENAI_COMPATIBLE_ALLOW_SHELL:-1}"
    
    if [ -z "${OPENAI_COMPATIBLE_ENDPOINT:-}" ]; then
        if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
            export OPENAI_COMPATIBLE_ENDPOINT="https://api.deepseek.com/chat/completions"
            export OPENAI_COMPATIBLE_MODEL="${OPENAI_COMPATIBLE_MODEL:-deepseek-chat}"
            export OPENAI_COMPATIBLE_API_KEY="$DEEPSEEK_API_KEY"
            echo "→ Configured with DeepSeek endpoint: $OPENAI_COMPATIBLE_ENDPOINT ($OPENAI_COMPATIBLE_MODEL)"
        elif [ -n "${OPENROUTER_API_KEY:-}" ]; then
            export OPENAI_COMPATIBLE_ENDPOINT="https://openrouter.ai/api/v1/chat/completions"
            export OPENAI_COMPATIBLE_MODEL="${OPENAI_COMPATIBLE_MODEL:-anthropic/claude-3.5-sonnet}"
            export OPENAI_COMPATIBLE_API_KEY="$OPENROUTER_API_KEY"
            echo "→ Configured with OpenRouter endpoint: $OPENAI_COMPATIBLE_ENDPOINT ($OPENAI_COMPATIBLE_MODEL)"
        else
            echo "⚠️ Warning: No OPENAI_COMPATIBLE_ENDPOINT configured. Please set it in .auto-loop.env"
        fi
    fi
fi

# Preflight check macOS isolation compatibility
if ! python3 "$ROOT_DIR/scripts/core/project_isolation.py" --check >/dev/null 2>&1; then
    echo "❌ Error: Project isolation preflight failed."
    exit 1
fi
echo "✓ Project isolation check passed (macOS native compatibility active)"

MODE="${1:-start}"

case "$MODE" in
    dashboard|center)
        echo "→ Launching Product Center Dashboard on http://127.0.0.1:8810/center..."
        python3 "$ROOT_DIR/dashboard/center_server.py" --port 8810
        ;;
    status)
        bash "$ROOT_DIR/scripts/core/monitor.sh" --status
        ;;
    stop)
        bash "$ROOT_DIR/scripts/core/stop-loop.sh"
        ;;
    start)
        echo "→ Starting autonomous loop (Press Ctrl+C to stop)..."
        echo "→ Dashboard will be available at http://127.0.0.1:8810/center (start in a separate terminal via './scripts/launch-macos.sh dashboard')"
        exec bash "$ROOT_DIR/scripts/core/auto-loop.sh"
        ;;
    *)
        echo "Usage: $0 [start|dashboard|status|stop]"
        exit 1
        ;;
esac
