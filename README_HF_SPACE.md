---
title: Insight Weaver
emoji: 🧬
colorFrom: indigo
colorTo: blue
sdk: docker
app_port: 7860
pinned: false
license: mit
---

# Insight Weaver

Gemma-powered scientific discovery copilot for paper ingestion, GraphRAG, knowledge graph exploration, contradiction detection, and hypothesis generation.

The full project README is available in `README.md`.

## Hugging Face Space Notes

This Space uses the root `Dockerfile`, which packages:

- React frontend
- FastAPI backend
- Nginx proxy
- optional local Ollama runtime

Default Space model:

```env
OLLAMA_MODEL=gemma4:e2b
```

For better performance, use paid CPU/GPU hardware with persistent storage enabled, or set:

```env
USE_EXTERNAL_OLLAMA=true
OLLAMA_HOST=<your_ollama_or_ollama_cloud_endpoint>
OLLAMA_MODEL=<model_tag>
```
