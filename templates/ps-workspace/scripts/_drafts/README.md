# `scripts/_drafts/` — script staging (portable)

Ad-hoc PowerShell scripts for a **single task** live here before promotion into
`scripts/`. Keeps the promoted tree free of one-offs.

---

## What belongs here

| Candidate | Decision |
|-----------|----------|
| One-shot / task-specific script | Stay in `_drafts/` |
| Possibly reusable but untested | `_drafts/` — add `# CANDIDATE: <why>` near the top |
| Clearly general-purpose (`param()`, help, tier, tests ready) | Promote to `scripts/` |

**Never** commit secrets, hard-coded credentials, or machine-specific absolute
paths without a TODO to remove them before promotion.

---

## Promotion criteria

Promote when **all** hold:

| Criterion | Check |
|-----------|-------|
| Reusable | Useful beyond the original one-off |
| Parameterized | `param()`; no hard-coded task paths |
| Quality bar | Header with `#requires`, tier-first `.DESCRIPTION`, StrictMode, `$ErrorActionPreference` |
| Safe output | Stable JSON and/or exit codes; side effects match declared Safety tier |
| Tier assigned | `**Safety tier: N**` first `.DESCRIPTION` line, blank help line, then body |
| Tests | At least one Pester case under `tests/` when behaviour is non-trivial |

---

## How to promote

1. Meet the criteria above.
2. Move `scripts/_drafts/<Name>.ps1` → `scripts/<Name>.ps1` (VCS-aware rename).
3. Add or extend `tests/` coverage.
4. Run PSA: `Invoke-ScriptAnalyzer -Path .\scripts -Settings .\PSScriptAnalyzerSettings.psd1 -Recurse`
5. Record the promotion in the project changelog if required.

---

*Pack: templates/ps-workspace/*
