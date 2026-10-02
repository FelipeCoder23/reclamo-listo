# Scoping

Status: **draft** — to be completed during Phase 0, before any code is written.

## 1. Discovery

Goal: talk to 3–5 people who had a problem with a purchase in the last year. Capture what happened, what they did, where they got stuck, and what would have helped.

### Interview guide (15–20 min, informal)

1. Tell me about the last time a purchase went wrong. What did you buy, where, what happened?
2. What did you do first? Did you contact the store? How did that go?
3. Did you know you could complain to SERNAC? Did you try? What stopped you, or what was hard?
4. Did you know what your rights were? Where did you look?
5. If a tool had given you a written complaint and a message for the store, would you have used it? What would make you distrust it?
6. How did it end?

### Interviews

| # | Date | Profile (age range, how they shop) | Problem type | Key quote | Where they got stuck |
|---|------|------------------------------------|--------------|-----------|----------------------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |

### Findings

_Patterns across interviews. What surprised you. What this changes about the product._

## 2. Problem statement

_One paragraph. Who has the problem, when, what it costs them today._

## 3. Target user

_Primary persona. What they know about their rights (usually little), what device they use (mostly phone), how much patience they have._

## 4. In scope (MVP)

Categories handled:
- Garantía legal (defective product within 6 months)
- Retracto (right of withdrawal, e-commerce)
- Compra cancelada unilateralmente por la tienda
- Incumplimiento (not delivered, late, different from what was offered)
- Cobro indebido
- Publicidad engañosa

Corpus: Ley 19.496 and Decreto 6/2021 only.

## 5. Out of scope

Labor, rental, financial debt (Dicom), health, telecom regulator (SUBTEL) cases, anything requiring a receipt photo, user accounts, history, automatic submission to SERNAC. See `docs/plan.md` §12.

## 6. Success metrics (defined before building)

| Metric | Target | How measured |
|--------|--------|--------------|
| Invented citations | 0 | evals |
| Category accuracy | set after first real run, only goes up | evals |
| Out-of-scope rejection | set after first real run | evals |
| p95 latency | < 15 s | Cloud Monitoring |
| Cost per request | < US$0.01 | logs |
| Monthly cost | < US$5 | billing |
| Usability | one person outside the project completes a request on a phone with no explanation | Phase 4 test |

## 7. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Model cites wrong or invented articles | medium | high | retrieval-only citations + deterministic verifier |
| Users treat output as legal advice | high | medium | visible disclaimer, "orienta, no reemplaza asesoría" |
| Confusion with official SERNAC site | low | high | distinct name and design, explicit non-affiliation |
| Abuse drives cost | medium | medium | per-user and global daily caps, budget alerts |
| Carrier NAT makes IP-based limits block legitimate users | medium | medium | signed cookie as primary key, IP hash as fallback (decide in Phase 3) |
| Law changes and corpus goes stale | low | medium | corpus versioned in repo; update is a PR that triggers evals |
| No lawyer available to validate golden cases | medium | medium | ship marked "sin validar"; keep looking |

## 8. Open questions

- Who reviews the golden cases (lawyer)?
- Final name and domain. Check for trademark conflicts and SERNAC confusion.
- Exact Gemini Flash model id at build time.
