# ADR 0003: Public repository from day one

Date: 2026-10-02
Status: accepted

## Context

The repo started private. GitHub branch protection rules (required PRs, required status checks, no force-push) are free only on public repos. The project is a portfolio piece whose value depends on being readable by others.

## Decision

Make the repository public now. Never commit secrets; rely on gitleaks in pre-commit and CI, Secret Manager for runtime secrets, and Workload Identity Federation instead of service account keys.

## Consequences

- Branch protection available at no cost from Phase 1.
- Every commit is visible, including mistakes. That is acceptable and part of the learning log.
- Security posture must assume the code is public: no "it's private anyway" shortcuts.
