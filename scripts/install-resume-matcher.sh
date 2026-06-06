#!/usr/bin/env bash
# Pipeline — one-shot Resume Matcher install (Mac / Linux)
# curl -fsSL https://raw.githubusercontent.com/domabyte/Job_tracker/main/scripts/install-resume-matcher.sh | bash

set -euo pipefail

PORT="${RESUME_MATCHER_PORT:-18765}"

mkdir -p ~/resume-matcher && cd ~/resume-matcher

cat > docker-compose.yml << 'EOF'
services:
  resume-matcher:
    image: ghcr.io/srbhr/resume-matcher:latest
    container_name: pipeline-resume-matcher
    ports:
      - "18765:3000"
    volumes:
      - resume-matcher-data:/app/backend/data
    environment:
      - FRONTEND_BASE_URL=http://127.0.0.1:3000
      - LOG_LEVEL=INFO
      - CORS_ORIGINS=["http://localhost:18765","http://127.0.0.1:18765","http://localhost:8080","http://127.0.0.1:8080","http://localhost:5500","http://127.0.0.1:5500","http://localhost:5173","http://127.0.0.1:5173","https://domabyte.github.io"]
    restart: unless-stopped

volumes:
  resume-matcher-data:
EOF

command -v docker >/dev/null 2>&1 || { echo "Install Docker Desktop first."; exit 1; }
docker info >/dev/null 2>&1 || { echo "Open Docker Desktop until Running, then run again."; exit 1; }

docker rm -f pipeline-resume-matcher 2>/dev/null || true
docker compose -f docker-compose.yml up -d

echo ""
echo "Pipeline URL: http://localhost:${PORT}"
echo "Need Chrome flag? → chrome://flags/#unsafely-treat-insecure-origin-as-secure"
