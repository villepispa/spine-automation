# Changelog

All notable changes to **Spine.Automation** are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning aligns with [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Issue register: [docs/issues.md](docs/issues.md).

## [Unreleased]

### Added

- **`-AgentSummary` on smoke scripts** — `scripts/Invoke-SpinePs51SmokeTest.ps1` and
  `scripts/Test-SpineProductShellGuard.ps1` accept `-AgentSummary` and emit
  `SPINE-SMOKE-*` / `SPINE-PRODUCT-SHELLGUARD-SMOKE-*` lines for agent Shell gates.
- **Product ShellGuard pilot (`SPA-006`)** — `.cursor/hooks/` Safety-tier gate for
  agent `pwsh -File` (slim pack; not full config ShellGuard); smoke via
  `scripts/Test-SpineProductShellGuard.ps1`; documented in `docs/consumption.md`.
- **Product changelog + issue register (`SPA-005`)** — Keep a Changelog layout;
  `docs/issues.md` with stable `SPA-` identifiers cross-linked from release notes.

## [0.1.1] — 2026-07-17

### Added

- **Probe envelope helpers (`SPA-002`)** — `New-SpineProbeEnvelope`,
  `Write-SpineProbeEnvelope`, `Assert-SpineProbeEnvelope` (and related probe
  helpers) for the standard `{ ok, exitCode, safetyTier, summary, data }`
  contract; `ModuleVersion` `0.1.1`.
- **Dual-host CI (`SPA-004`)** — `.github/workflows/dual-host-ps.yml` (Pester
  matrix on `pwsh` + Windows PowerShell, plus PS 5.1 smoke); documented in
  `docs/consumption.md`.

### Changed

- **Public-tree redaction (`SPA-003`)** — Removed private workspace vocabulary
  from module comments, tests, and docs destined for public sharing.

## [0.1.0] — 2026-07-15

### Added

- **Initial public spike (`SPA-001`)** — Runtime, Repo, Process, and Probe
  shards; MIT license; `docs/consumption.md`; Pester unit tests and PS 5.1
  smoke script.
