# ADR 0002: Two LLM calls on the happy path, three as a hard maximum

Date: 2026-10-02
Status: accepted

## Context

The pipeline has two LLM steps (classify, draft) and a deterministic citation verifier. If the verifier rejects the draft, the options are: answer "sin certeza" immediately, or retry the draft once. The plan originally said "two calls maximum", which forbids the retry.

## Decision

Allow exactly one retry of the draft step when verification fails. Happy path: 2 calls. Worst case: 3. The agent code enforces the hard limit; it is not left to configuration.

## Consequences

- Slightly higher worst-case cost and latency, bounded and measured in Phase 5.
- Fewer "sin certeza" answers for users a second pass would have helped.
- The retry rate becomes a monitored metric: a rising rate signals a prompt or corpus regression.
