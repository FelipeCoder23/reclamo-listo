# Reclamo Listo — conventions for Claude Code

Source of truth: `docs/plan.md`. Read it before any non-trivial change.

## How we work (learning mode)
- Explain before writing: 3–5 lines on what a workflow, Dockerfile or Terraform module does and why it exists, before creating it.
- One phase at a time. Do not start work from a later phase.
- Everything goes through a Pull Request once Phase 1 is complete. No direct pushes to `main` after that.
- Cloud steps (project creation, identity federation, first `terraform apply`) are run by the user the first time. Prepare the commands, do not run them.
- Verify library versions (ADK, Next.js) before pinning dependencies.
- Each phase closes with: criteria met, an ADR if a decision was made, and 5 lines in `docs/learning-log.md`.
- Break things on purpose once per phase (failing test, fake secret, degraded eval).

## Hard rules
- Never store, log or trace the user's story (`relato`). IP only as salted hash with TTL.
- The LLM interprets and drafts; anything deterministic lives in code with tests.
- Every cited article must exist in the retrieved set. No valid citation, no answer.
- Max 3 LLM calls per request (2 on the happy path).
- Do not add technology the product does not need.
- Tests in CI never call the real model. Only `evals.yml` and the deploy smoke test do.

## Language
- Repo docs, filenames in `docs/`, commit messages, code identifiers and comments: English.
- UI text and domain vocabulary (categories, SERNAC complaint text, API field names like `relato`, `reclamo_sernac`): Chilean Spanish.

## Stack
Backend: Python 3.12+, FastAPI, Google ADK, Pydantic, `uv`, `ruff`, `mypy`, `pytest` (80% coverage).
Frontend: Next.js + TypeScript, Vitest, types generated from OpenAPI.
Infra: Terraform, Cloud Run (api private, web public), Firestore, Vertex AI (Gemini Flash), Artifact Registry. Region `us-central1`.
CI: GitHub Actions with Workload Identity Federation. No service account keys, ever.

## Commits
Conventional commits: `feat:`, `fix:`, `ci:`, `docs:`, `infra:`, `test:`, `chore:`.
