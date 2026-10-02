# ADR 0001: Record architecture decisions

Date: 2026-10-02
Status: accepted

## Context

This project exists partly to show how decisions were made, not just what was built. Decisions scattered across chat sessions and commit messages are lost.

## Decision

Use Architecture Decision Records, one file per decision, in `docs/adr/`, numbered sequentially. Format: Context, Decision, Consequences. Status is `proposed`, `accepted`, `deprecated` or `superseded by ADR-XXXX`.

## Consequences

Every closed decision in `docs/plan.md` §1 that someone could reasonably challenge gets its own ADR as it is implemented (Cloud Run over Agent Engine, ADK over LangGraph, embeddings in the image, no vector DB, max 3 LLM calls, public repo).
