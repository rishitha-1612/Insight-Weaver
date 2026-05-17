FROM node:22-alpine AS frontend-build

WORKDIR /frontend

ARG VITE_API_BASE=/api/v1
ENV VITE_API_BASE=$VITE_API_BASE

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=7860 \
    HF_SPACE_LIGHT_MODE=true

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx ca-certificates bash \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip \
    && pip install fastapi==0.115.6 uvicorn[standard]==0.34.0 python-multipart==0.0.20

COPY hf/space_api.py /app/space_api.py
COPY --from=frontend-build /frontend/dist /app/frontend/dist
COPY hf/nginx.conf /etc/nginx/nginx.conf
COPY hf/start-space.sh /app/start-space.sh

RUN chmod +x /app/start-space.sh \
    && mkdir -p /data/uploads /run/nginx

EXPOSE 7860

CMD ["/app/start-space.sh"]
