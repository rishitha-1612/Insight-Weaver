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

Default public-demo mode:

```env
HF_SPACE_LIGHT_MODE=true
OLLAMA_MODEL=gemma4:e2b
```

In this mode, the Space does not download local Ollama/Gemma during startup. This avoids restart timeouts on basic Hugging Face hardware.

For Gemma-backed inference, set:

```env
USE_EXTERNAL_OLLAMA=true
OLLAMA_HOST=<your_ollama_or_ollama_cloud_endpoint>
OLLAMA_MODEL=<model_tag>
```

Running Ollama inside the Space requires stronger paid hardware and persistent storage.
