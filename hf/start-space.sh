#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-7860}"

mkdir -p /data/uploads

echo "Starting Hugging Face safe-mode API"
cd /app
uvicorn space_api:app --host 127.0.0.1 --port 8000 &
BACKEND_PID="$!"

echo "Starting Nginx frontend on port ${PORT}"
nginx -g "daemon off;" &
NGINX_PID="$!"

wait -n "$BACKEND_PID" "$NGINX_PID"
