#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-7860}"
export OLLAMA_MODEL="${OLLAMA_MODEL:-gemma4:e2b}"
export GEMMA_REASONING_MODEL="${GEMMA_REASONING_MODEL:-$OLLAMA_MODEL}"
export GEMMA_LIGHT_MODEL="${GEMMA_LIGHT_MODEL:-$OLLAMA_MODEL}"
export POSTGRES_DSN="${POSTGRES_DSN:-sqlite+aiosqlite:////data/scidb.db}"
export CHROMA_PATH="${CHROMA_PATH:-/data/chroma_db}"
export UPLOADS_DIR="${UPLOADS_DIR:-/data/uploads}"
export OLLAMA_MODELS="${OLLAMA_MODELS:-/data/ollama/models}"

mkdir -p /data/uploads /data/chroma_db "$OLLAMA_MODELS"

if [[ "${USE_EXTERNAL_OLLAMA:-false}" == "true" ]]; then
  echo "Using external Ollama host: ${OLLAMA_HOST}"
else
  export OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
  echo "Starting local Ollama on ${OLLAMA_HOST} with model ${OLLAMA_MODEL}"
  ollama serve &
  OLLAMA_PID="$!"

  for attempt in $(seq 1 60); do
    if ollama list >/dev/null 2>&1; then
      break
    fi
    echo "Waiting for Ollama to start... (${attempt}/60)"
    sleep 2
  done

  if ! ollama list | awk '{print $1}' | grep -qx "${OLLAMA_MODEL}"; then
    echo "Pulling ${OLLAMA_MODEL}. This may take several minutes on first Space startup."
    ollama pull "${OLLAMA_MODEL}"
  else
    echo "${OLLAMA_MODEL} already available."
  fi
fi

echo "Starting FastAPI backend"
cd /app/backend
uvicorn api.main:app --host 127.0.0.1 --port 8000 &
BACKEND_PID="$!"

echo "Starting Nginx frontend on port ${PORT}"
nginx -g "daemon off;" &
NGINX_PID="$!"

if [[ -n "${OLLAMA_PID:-}" ]]; then
  wait -n "$BACKEND_PID" "$NGINX_PID" "$OLLAMA_PID"
else
  wait -n "$BACKEND_PID" "$NGINX_PID"
fi
