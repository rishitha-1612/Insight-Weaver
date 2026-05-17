FROM node:22-alpine AS frontend-build

WORKDIR /frontend

ARG VITE_API_BASE=/api/v1
ENV VITE_API_BASE=$VITE_API_BASE

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

FROM ollama/ollama:latest AS ollama-bin

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=7860 \
    OLLAMA_MODEL=gemma4:e2b \
    OLLAMA_HOST=http://127.0.0.1:11434 \
    OLLAMA_MODELS=/data/ollama/models \
    GEMMA_REASONING_MODEL=gemma4:e2b \
    GEMMA_LIGHT_MODEL=gemma4:e2b \
    POSTGRES_DSN=sqlite+aiosqlite:////data/scidb.db \
    CHROMA_PATH=/data/chroma_db \
    UPLOADS_DIR=/data/uploads \
    INDEX_VECTORS_DURING_PROCESSING=false \
    CORS_ORIGINS='["http://localhost:7860","http://127.0.0.1:7860"]'

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl git libpq-dev nginx ca-certificates bash \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ollama-bin /bin/ollama /usr/local/bin/ollama

COPY backend/requirements.txt /app/backend/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r /app/backend/requirements.txt \
    && pip install aiosqlite==0.20.0

COPY backend/ /app/backend/
COPY --from=frontend-build /frontend/dist /app/frontend/dist
COPY hf/nginx.conf /etc/nginx/nginx.conf
COPY hf/start-space.sh /app/start-space.sh

RUN chmod +x /app/start-space.sh \
    && mkdir -p /data/uploads /data/chroma_db /data/ollama/models /run/nginx

EXPOSE 7860

CMD ["/app/start-space.sh"]
