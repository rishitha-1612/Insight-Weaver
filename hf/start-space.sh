#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-7860}"
export OLLAMA_MODEL="${OLLAMA_MODEL:-gemma4:e2b}"
export GEMMA_REASONING_MODEL="${GEMMA_REASONING_MODEL:-$OLLAMA_MODEL}"
export GEMMA_LIGHT_MODEL="${GEMMA_LIGHT_MODEL:-$OLLAMA_MODEL}"
export POSTGRES_DSN="${POSTGRES_DSN:-sqlite+aiosqlite:////data/scidb.db}"
export CHROMA_PATH="${CHROMA_PATH:-/data/chroma_db}"
export UPLOADS_DIR="${UPLOADS_DIR:-/data/uploads}"

mkdir -p /data/uploads /data/chroma_db

if [[ "${USE_EXTERNAL_OLLAMA:-false}" == "true" ]]; then
  echo "Using external Ollama host: ${OLLAMA_HOST}"
else
  echo "HF Space light mode: local Ollama is disabled to avoid startup timeouts."
  echo "Set USE_EXTERNAL_OLLAMA=true and OLLAMA_HOST to enable Gemma-backed generation."
fi

echo "Starting FastAPI backend"
cd /app/backend
uvicorn api.main:app --host 127.0.0.1 --port 8000 &
BACKEND_PID="$!"

echo "Starting Nginx frontend on port ${PORT}"
nginx -g "daemon off;" &
NGINX_PID="$!"

wait -n "$BACKEND_PID" "$NGINX_PID"
