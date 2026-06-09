# Pipeline — one-shot Resume Matcher install (Windows PowerShell)
# irm https://raw.githubusercontent.com/domabyte/Job_tracker/main/scripts/install-resume-matcher.ps1 | iex

$ErrorActionPreference = 'Stop'
$dir = Join-Path $env:USERPROFILE 'resume-matcher'
$port = if ($env:RESUME_MATCHER_PORT) { $env:RESUME_MATCHER_PORT } else { '18765' }

New-Item -ItemType Directory -Force -Path $dir | Out-Null
Set-Location $dir

@'
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
'@ | Set-Content -Encoding utf8 docker-compose.yml

docker info *> $null
if (-not $?) { Write-Host 'Open Docker Desktop first.'; exit 1 }

# Ignore "No such container" on first install (bash: 2>/dev/null || true)
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
docker rm -f pipeline-resume-matcher *> $null
$ErrorActionPreference = $prevEap
docker compose -f docker-compose.yml up -d

Write-Host ""
Write-Host "Pipeline URL: http://localhost:$port"
