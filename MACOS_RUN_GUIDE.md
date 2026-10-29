# Autonomous Company — macOS Quickstart & Run Guide

Welcome to **Autonomous Company** running on macOS (Apple Silicon & Intel).

This installation has been patched with native macOS compatibility for the v3.0 project isolation layer, allowing seamless multi-agent business operations and product creation directly on Darwin without requiring Linux or WSL2.

---

## 🚀 1. One-Click Commands

Run these from the repository root:

### Start the Autonomous Loop
```bash
./scripts/launch-macos.sh start
# or standard Makefile
make start
```

### Launch the Visual Dashboard (Product Center)
```bash
./scripts/launch-macos.sh dashboard
# or:
make dashboard
```
Then open your browser to **[http://127.0.0.1:8810/center](http://127.0.0.1:8810/center)**.

### Check Current Loop Status
```bash
make status
```

### Stop the Loop Gracefully
```bash
make stop
```

---

## 🔑 2. Configuring Your API Keys

You can configure your model backends either in your shell (`~/.zshrc`) or locally in `.auto-loop.env` (which is git-ignored and never committed):

### Option A: Claude Code (Default)
Claude Code CLI is installed at `/Users/likhith/.npm-global/bin/claude`.
To run with Claude Code, either run:
```bash
claude login
```
Or export your Anthropic key:
```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

### Option B: OpenAI-Compatible (DeepSeek, OpenRouter, Groq, Ollama)
Copy `.auto-loop.env.example` to `.auto-loop.env`:
```bash
cp .auto-loop.env.example .auto-loop.env
```
And set:
```bash
ENGINE=openai-compatible
OPENAI_COMPATIBLE_ADAPTER_ENABLED=1
OPENAI_COMPATIBLE_ENDPOINT="https://api.deepseek.com/chat/completions"
OPENAI_COMPATIBLE_MODEL="deepseek-chat"
OPENAI_COMPATIBLE_API_KEY="your-key-here"
OPENAI_COMPATIBLE_ALLOW_SHELL=1
```

---

## 💼 3. Business Goal & Revenue Focus

The autonomous loop works in continuous cycles:
1. Reads `PROMPT.md` for company strategy and direction.
2. Coordinates 14 expert AI roles (CEO, CTO, Don Norman Product Design, Seth Godin Marketing, DHH Full-Stack, etc.).
3. Researches target audiences, builds software solutions in `projects/`, designs landing pages, tests code, and prepares revenue generation flows.
4. Records all progress into `memories/consensus.md` and displays real-time telemetry on the Product Center dashboard.

To steer the company toward a specific niche or revenue target, update `PROMPT.md` or add notes in `## Human Overrides` inside `memories/consensus.md`.
