# Spine.Automation — issue register

This register tracks actionable findings and shipped product work for the
module. Prefer stable `SPA-` identifiers in commits, tests, and release notes.

## Workflow

- **Status:** `Open` → `In progress` → `Resolved` → `Verified`
- **Severity:** `High`, `Medium`, or `Low` (defects); omit for shipped features
- Keep issue identifiers stable; never reuse an ID
- Add resolution evidence before changing an issue to `Verified`

## Open issues

_(None.)_

## Resolved issues (2026-07-17 — SPA-006)

| ID | Summary | Evidence |
|----|---------|----------|
| SPA-006 | Lightweight product ShellGuard project hooks (Safety tier on `pwsh -File`) | `.cursor/hooks.json`; `.cursor/hooks/Invoke-ProductShellGuard.ps1`; `scripts/Test-SpineProductShellGuard.ps1`; `docs/consumption.md` |

## Resolved issues (2026-07-17 — SPA-005)

| ID | Summary | Evidence |
|----|---------|----------|
| SPA-005 | Keep a Changelog + this issue register; README documentation links | `CHANGELOG.md`; `docs/issues.md`; `README.md` |

## Resolved issues (2026-07-17 — v0.1.1)

| ID | Summary | Evidence |
|----|---------|----------|
| SPA-002 | Probe envelope helpers for standard JSON / AgentSummary contract | `Private/Spine.Probe.ps1`; `tests/unit/Spine.Probe.Tests.ps1`; `ModuleVersion` `0.1.1` |
| SPA-003 | Scrub private workspace IDs and absolute paths from public product tree | Module comments/tests/docs clean of private backlog prefixes |
| SPA-004 | Dual-host GitHub Actions workflow (Pester matrix + PS 5.1 smoke) | `.github/workflows/dual-host-ps.yml`; `docs/consumption.md` § Continuous integration |

## Resolved issues (2026-07-15 — v0.1.0)

| ID | Summary | Evidence |
|----|---------|----------|
| SPA-001 | Initial public module spike (Runtime, Repo, Process, Probe) | `src/Spine.Automation/`; `tests/unit/`; `scripts/Invoke-SpinePs51SmokeTest.ps1`; `docs/consumption.md` |

## Activity

<!-- ISSUES-ACTIVITY+ -->
- **2026-07-17 11:41:00** — Added `SPA-006` (product ShellGuard pilot hooks + smoke).
- **2026-07-17 09:19:27** — Added `SPA-005` (changelog + issue register harmonization). Backfilled `SPA-001`–`SPA-004` into Keep a Changelog releases `0.1.0` / `0.1.1`.
- **2026-07-17** — Verified `SPA-004` dual-host workflow dry-run (Pester both hosts + PS 5.1 smoke).
- **2026-07-16** — Resolved `SPA-002` (probe envelopes) and `SPA-003` (public-tree redaction).
- **2026-07-15** — Resolved `SPA-001` (initial spike); repo hosted under the OSS product tree.
