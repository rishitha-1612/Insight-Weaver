from __future__ import annotations

import time
from pathlib import Path
from uuid import uuid4

from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI(title="Insight Weaver Space API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = Path("/data/uploads")
PAPERS: list[dict] = []


@app.get("/health")
async def health() -> dict:
    return {"status": "ok", "mode": "huggingface-safe-demo"}


@app.get("/api/v1/agents/model-status")
async def model_status() -> dict:
    return {
        "status": "demo",
        "model": "Gemma via Ollama",
        "message": (
            "Hugging Face safe demo is running. Full Gemma/Ollama inference is available "
            "in the Docker deployment or by configuring an external Ollama endpoint."
        ),
        "response": "safe-demo",
        "duration_seconds": 0,
    }


@app.post("/api/v1/auth/login")
async def login(payload: dict) -> dict:
    username = payload.get("username") or "researcher"
    return {"user": {"username": username, "display_name": username.title()}}


@app.post("/api/v1/auth/signup")
async def signup(payload: dict) -> dict:
    username = payload.get("username") or "researcher"
    return {"user": {"username": username, "display_name": username.title()}}


@app.post("/api/v1/papers/upload")
async def upload_paper(file: UploadFile = File(...)) -> dict:
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    paper_id = len(PAPERS) + 1
    safe_name = file.filename or f"paper-{paper_id}.pdf"
    path = UPLOAD_DIR / f"{uuid4()}_{safe_name}"
    path.write_bytes(await file.read())
    row = {
        "id": paper_id,
        "title": safe_name,
        "authors": [],
        "publication_year": None,
        "processing_status": "completed",
        "uploaded_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "abstract": (
            "This paper was uploaded to the Hugging Face public demo. The full local deployment "
            "performs scientific PDF parsing, entity extraction, graph construction, and Gemma reasoning."
        ),
        "doi": None,
        "arxiv_id": None,
        "pubmed_id": None,
        "journal": None,
        "chunks_count": 1,
        "entities_count": 5,
    }
    PAPERS.insert(0, row)
    return {"paper_id": paper_id, "title": safe_name, "status": "processing", "task_id": f"hf-demo-{paper_id}"}


@app.get("/api/v1/papers/")
async def list_papers(limit: int = 100, offset: int = 0) -> list[dict]:
    return PAPERS[offset : offset + limit]


@app.get("/api/v1/papers/{paper_id}")
async def get_paper(paper_id: int) -> dict:
    for paper in PAPERS:
        if paper["id"] == paper_id:
            return paper
    return {
        "id": paper_id,
        "title": "Demo paper",
        "authors": [],
        "publication_year": None,
        "processing_status": "completed",
        "abstract": "Demo paper metadata.",
        "chunks_count": 1,
        "entities_count": 5,
    }


@app.get("/api/v1/papers/{paper_id}/status")
async def paper_status(paper_id: int) -> dict:
    return {
        "paper_id": paper_id,
        "status": "completed",
        "chunks_created": 1,
        "entities_extracted": 5,
        "graph_built": True,
    }


@app.post("/api/v1/search")
@app.post("/api/v1/search/graphrag")
async def graph_rag(payload: dict) -> dict:
    query = payload.get("query", "the research question")
    return {
        "answer": (
            "### Hugging Face Public Demo\n"
            f"Insight Weaver received the query: **{query}**.\n\n"
            "The full Docker/Ollama deployment parses PDFs, chunks sections, extracts scientific entities, "
            "builds a knowledge graph, runs GraphRAG, detects contradictions, and generates hypotheses with Gemma. "
            "This Space is configured as a safe public demo so it starts reliably on Hugging Face basic hardware."
        ),
        "model": "hf-safe-demo",
        "warnings": [
            "Full Gemma/Ollama inference is disabled in this public Space to avoid startup timeouts.",
            "Use the Docker deployment or configure external Ollama for model-backed generation.",
        ],
        "results": [
            {
                "id": "demo-1",
                "text": "Insight Weaver converts research papers into evidence chunks, entities, graph relationships, and testable hypotheses.",
                "metadata": {"paper_id": 1, "title": "Insight Weaver Demo", "section": "overview"},
                "similarity_score": 0.91,
            }
        ],
        "graph_context": {
            "entities": [
                {"id": 1, "name": "GraphRAG", "type": "METHOD", "paper_count": 1},
                {"id": 2, "name": "Gemma", "type": "MODEL", "paper_count": 1},
                {"id": 3, "name": "Knowledge Graph", "type": "CONCEPT", "paper_count": 1},
            ],
            "relationships": [
                {
                    "source": "GraphRAG",
                    "relationship": "uses",
                    "target": "Knowledge Graph",
                    "confidence": 0.95,
                    "paper_id": 1,
                    "kind": "demo",
                }
            ],
            "papers": [{"id": 1, "title": "Insight Weaver Demo"}],
        },
        "query_time_ms": 10,
    }


@app.get("/api/v1/graph/{paper_id}")
async def graph_for_paper(paper_id: int) -> dict:
    return {
        "nodes": [
            {"id": f"paper-{paper_id}", "label": "Uploaded Paper", "type": "Paper", "paper_count": 1},
            {"id": "entity-1", "label": "GraphRAG", "type": "METHOD", "mention_count": 3},
            {"id": "entity-2", "label": "Gemma", "type": "MODEL", "mention_count": 2},
            {"id": "entity-3", "label": "Knowledge Graph", "type": "CONCEPT", "mention_count": 4},
        ],
        "edges": [
            {"source": f"paper-{paper_id}", "target": "entity-1", "type": "MENTIONS"},
            {"source": f"paper-{paper_id}", "target": "entity-2", "type": "MENTIONS"},
            {"source": "entity-1", "target": "entity-3", "type": "uses", "confidence": 0.95},
        ],
    }


@app.get("/api/v1/graph/entity/{entity_name}")
async def graph_for_entity(entity_name: str) -> dict:
    return await graph_for_paper(1)


@app.post("/api/v1/hypothesis/generate")
async def generate_hypothesis(payload: dict) -> dict:
    query = payload.get("query", "the research area")
    return {
        "hypotheses": [
            {
                "id": 1,
                "hypothesis": (
                    f"For {query}, combining graph-grounded retrieval with Gemma-based reasoning will produce "
                    "more testable research directions than plain document search."
                ),
                "reasoning": (
                    "The system first structures paper evidence into chunks, entities, and relationships. "
                    "This gives the model grounded context before it proposes hypotheses."
                ),
                "supporting_evidence": [
                    {
                        "paper_title": "Insight Weaver Demo",
                        "section": "system design",
                        "excerpt": "GraphRAG connects retrieved text with graph relationships.",
                        "relevance": "Shows why graph context improves hypothesis generation.",
                    }
                ],
                "confidence": 0.72,
                "novelty_score": 0.68,
                "testability": "high",
                "suggested_experiments": [
                    "Compare hypothesis quality from plain RAG versus GraphRAG on the same paper set.",
                    "Measure groundedness, novelty, and expert usefulness.",
                ],
                "falsifiable_conditions": "If plain retrieval produces equal or better expert-rated hypotheses, the graph layer adds limited value.",
                "research_gaps_addressed": ["Grounded scientific ideation from uploaded literature."],
                "cross_domain_insight": "Combines information retrieval, graph mining, and local LLM inference.",
            }
        ],
        "meta_insights": {
            "dominant_themes": ["GraphRAG", "Gemma", "scientific discovery"],
            "most_promising_direction": "Use graph-grounded retrieval before generative hypothesis creation.",
            "critical_missing_experiments": ["Expert evaluation against standard literature search workflows."],
        },
        "warnings": ["Safe demo response. Configure external Ollama for live Gemma generation."],
    }


@app.post("/api/v1/analysis/contradictions")
async def contradictions(payload: dict) -> list[dict]:
    paper_ids = payload.get("paper_ids") or [1, 2]
    return [
        {
            "paper_a_id": paper_ids[0],
            "paper_b_id": paper_ids[-1],
            "topic": payload.get("topic", "demo topic"),
            "has_contradiction": False,
            "severity": "LOW",
            "contradiction_type": "demo",
            "paper_a_claim": "",
            "paper_b_claim": "",
            "explanation": "Safe demo mode does not run model-backed contradiction analysis.",
            "resolution_suggestion": "Deploy with external Ollama to enable live Gemma contradiction reasoning.",
        }
    ]


@app.post("/api/v1/analysis/connections")
async def connections(payload: dict) -> list[dict]:
    return [
        {
            "source_paper_id": payload.get("paper_id", 1),
            "target_paper_id": 1,
            "target_paper_title": "Insight Weaver Demo",
            "similarity_score": 0.88,
            "connection_score": 0.88,
            "source_excerpt": "GraphRAG links evidence chunks to graph entities.",
            "target_excerpt": "Knowledge graphs expose cross-paper relationships.",
            "shared_concepts": ["GraphRAG", "Knowledge Graph"],
        }
    ]


@app.post("/api/v1/analysis/landscape")
async def landscape(payload: dict) -> dict:
    return {
        "topic": payload.get("topic", "scientific discovery"),
        "paper_count": len(PAPERS),
        "year_range": None,
        "key_milestones": ["Public demo deployed on Hugging Face Spaces."],
        "paradigm_shifts": ["Moving from document search to graph-grounded research reasoning."],
        "open_questions": ["How should graph-grounded hypotheses be evaluated by domain experts?"],
        "trending_direction": "Evidence-grounded, local-first AI research assistants.",
    }
