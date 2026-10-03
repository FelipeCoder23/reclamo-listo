# Learning log

Five lines per phase: what I learned, what surprised me, what I would do differently.

## Phase 0 — Discovery, scoping and setup

Technical setup done 2026-10-02. Discovery interviews pending.

- Homebrew no longer ships Terraform (license change). The HashiCorp tap builds from source and needs current Xcode CLT; downloading the official binary is faster and equivalent.
- `gcloud billing budgets create` returns a bare `INVALID_ARGUMENT` for two different mistakes: `--filter-projects` needs the project *number*, not the ID, and the amount must be in the billing account's currency (CLP here). `--log-http` shows the request body and helps rule things out.
- Branch protection is free only on public repos, which settled the public/private question early.
- Budget alerts are per billing account, not per project, so the project filter matters when one account funds several projects.
- Cloud bootstrap steps done by hand should be written down the same day; they are the first thing a future maintainer cannot reconstruct from the code.
