# ADR 0004: The api service is protected by IAM, not by network ingress

Date: 2026-10-03
Status: accepted

## Context

The plan says the browser never talks to `api` directly; only the `web` service may call it. Cloud Run offers two ways to enforce that: network ingress (`internal` traffic only) or IAM (`roles/run.invoker` granted to a single identity).

Cloud Run treats a call from another Cloud Run service as *internal* only when it travels through a VPC (Direct VPC egress or a Serverless VPC Access connector). That adds a VPC, egress configuration and a connector cost to a product that otherwise needs no network at all.

## Decision

Keep `api` ingress open (`INGRESS_TRAFFIC_ALL`) and rely on IAM: no `allUsers` binding, and `roles/run.invoker` granted only to the `web` service account. `web` sends a Google-signed identity token with every call. Cloud Run rejects any request without a valid token before it reaches the container.

## Consequences

- No VPC, no connector, zero extra cost. Fits the "no technology the product does not need" rule.
- The api URL is public knowledge but unusable without a token minted for the `web` service account.
- If a stricter perimeter is ever required (VPC Service Controls, internal-only), it is an additive change: add Direct VPC egress to `web` and flip the ingress setting.
