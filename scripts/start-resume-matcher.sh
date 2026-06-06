#!/usr/bin/env bash
# One-command Resume Matcher setup for Pipeline.
# Usage (from anywhere):  ./scripts/start-resume-matcher.sh
# Or from repo root:       bash scripts/start-resume-matcher.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${RESUME_MATCHER_PORT:-18765}"
URL="http://localhost:${PORT}"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
info() { printf '→ %s\n' "$*"; }
err()  { printf '\033[0;31m✕ %s\033[0m\n' "$*" >&2; }

bold "Pipeline — Resume Matcher"
echo ""

if ! command -v docker >/dev/null 2>&1; then
  err "Docker is not installed."
  echo ""
  echo "  1. Install Docker Desktop (free):"
  echo "     Windows: https://docs.docker.com/desktop/setup/install/windows-install/"
  echo "     macOS:   https://docs.docker.com/desktop/setup/install/mac-install/"
  echo "     Linux:   https://docs.docker.com/desktop/setup/install/linux/"
  echo "  2. Open Docker Desktop and wait until it shows Running."
  echo "  3. Run this script again."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  err "Docker is installed but not running."
  echo ""
  echo "  Open Docker Desktop, wait until the whale icon says Running,"
  echo "  then run this script again."
  exit 1
fi

cd "$ROOT"
info "Starting Resume Matcher (first run downloads the image — may take a few minutes)…"
docker compose up -d

info "Waiting for Resume Matcher at ${URL} …"
for _ in $(seq 1 90); do
  if curl -sf "${URL}/api/v1/health" >/dev/null 2>&1; then
    echo ""
    bold "Resume Matcher is ready."
    echo ""
    echo "Set Pipeline URL to ${URL}"
    echo ""
    echo "  One-time AI setup: ${URL}/settings"
    echo "    • Add your API key (OpenAI, Gemini, OpenRouter, etc.) or use Ollama"
    echo ""
    exit 0
  fi
  sleep 2
  printf "."
done

echo ""
err "Container started but did not become healthy in time."
echo "  Check logs:  docker compose logs -f"
echo "  Retry:       ./scripts/start-resume-matcher.sh"
exit 1
