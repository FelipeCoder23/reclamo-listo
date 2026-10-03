# Reclamo Listo

> Describe a consumer problem in plain Chilean Spanish and get three things back: a verdict with the legal articles that apply, a complaint ready to paste into SERNAC (Chile's consumer protection agency), and a short message for the store.

**Status:** Phase 0 — technical setup done (GCP project, tooling, repo rules). Discovery interviews in progress. Nothing deployed yet. Next: Phase 1, starting with Workload Identity Federation bootstrap.

## Why

SERNAC received roughly 655,000 complaints in 2025, 22% of them about retail. General-purpose legal chatbots already exist; the gap is a tool that produces a *ready-to-send document* for a narrow, well-understood domain, and refuses to answer when it cannot cite the law.

## What this project demonstrates

This is a portfolio piece built the way a Forward Deployed Engineer ships an AI system: discovery → scoping → build → evaluate → deploy → operate → hand over.

- Production deployment anyone can use.
- Written discovery and scope *before* code.
- Agent quality measured with evals that block a bad deploy.
- Operability: cost tracking, traces, alerts, rollback, runbook.
- Documentation good enough for someone else to maintain it.

## Architecture (planned)

```
Browser ──HTTPS──▶ Cloud Run: web (Next.js)
                        │ server-to-server, IAM identity token
                        ▼
                   Cloud Run: api (FastAPI + Google ADK, private)
                        ├── Firestore     usage counters (hashed IP + day, global cap)
                        ├── Vertex AI     Gemini Flash + query embedding
                        └── local index   law articles + embeddings, baked into the image
```

Agent pipeline: **classify** (LLM) → **retrieve** (code) → **draft** (LLM) → **verify citations** (code). The LLM interprets and writes; everything deterministic lives in tested code. No valid citation, no answer.

Corpus: Ley 19.496 (Consumer Protection Act) and Decreto 6/2021 (E-commerce Regulation), sourced from LeyChile.

## Docs

- [Execution plan](docs/plan.md) — phases, decisions, CI/CD, security, evals.
- [Scoping](docs/scoping.md) — discovery findings, problem, user, success metrics.
- [ADRs](docs/adr/) — one decision per file.
- [Learning log](docs/learning-log.md) — what was learned per phase.

## Disclaimer

Reclamo Listo provides general guidance and does not replace legal advice. It is not affiliated with SERNAC or any Chilean government body.

## License

MIT — see [LICENSE](LICENSE).
