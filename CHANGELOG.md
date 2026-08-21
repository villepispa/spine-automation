# Changelog

All notable changes to **Spine.Automation** are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning aligns with [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Issue register: [docs/issues.md](docs/issues.md).

`[Unreleased]` stages changes for the **next** SemVer cut; it does not mean
the product is unpublished. Latest release is the first numbered section below.

## [Unreleased]

_Nothing queued — latest release: **0.1.6**._

## [0.1.6] — 2026-08-21

### Added

- **Probe envelope evidence ≠ receipt (`SPA-011`)** — optional `criteriaHash`
  (SHA-256 hex) and `contractId` on `New-SpineProbeEnvelope` /
  `Write-SpineProbeEnvelope`; `Get-SpineCriteriaHash` and
  `Test-SpineProbeCriteriaBinding`. Unbound `PREFIX-OK` envelopes fail the
  binding check. Envelope remains evidence, not an accept.

- **Product ShellGuard Pester-runner catalog (`SPA-010`)** — repo-root
  `tests/Invoke-*Pester.ps1` with a declared Safety tier is catalog (same
  effective-tier rules as `scripts/`). Template smoke fixtures; live
  `.cursor/hooks/` Core matches. Other `tests/` paths stay external.
- Repo-root markdownlint (`.markdownlint.json` + `.markdownlint-cli2.jsonc`
  ignores for `.cursor/` and drafts).
- Call-through VS Code tasks (`.vscode/tasks.json`); default ScriptSafetyGate
  path is `scripts/Invoke-SpineValidate.ps1`.

### Fixed

- **Public comment** — `scripts/Invoke-SpineValidate.ps1` help cites `SPA-009`
  instead of a private backlog ID.

## [0.1.5] — 2026-07-28

### Added

- **Agent-ready validate trio (`SPA-009`)** — `scripts/Invoke-SpineValidate.ps1`
  (PS 5.1 smoke → Pester → product PSA) with `-AgentSummary`;
  `tests/Invoke-SpinePester.ps1`; `scripts/Invoke-SpineScriptAnalyzer.ps1`;
  repo-root `PSScriptAnalyzerSettings.psd1`; README **Validate** section.
- **`templates/ps-workspace/`** — scrubbed portable bootstrap pack (no private
  backlog IDs); complements dual-host CI and ShellGuard packs.

### Fixed

- **`Write-SpineObjectArray` / `Get-SpineObjectArray`** — `process` blocks for
  `ValueFromPipeline` (clears `PSUseProcessBlockForPipelineCommand`).

## [0.1.4] — 2026-07-27

### Added

- **Consumer template packs (`SPA-008`)** — `templates/ps-dual-host-ci/` and
  `templates/ps-product-shellguard/` (portable copies; live pilots remain under
  `.github/workflows/` and repo-root `.cursor/hooks/`, local-only).
- **Related links** — README and `docs/consumption.md` point at
  [spine-cursor](https://github.com/villepispa/spine-cursor) probe plugin as the
  contract sibling of `Write-SpineProbe*` helpers.

### Fixed

- **`.gitignore` scope** — ignore only `/.cursor/` so
  `templates/ps-product-shellguard/.cursor/` remains trackable for consumers.

## [0.1.3] — 2026-07-26

### Fixed

- **`ConvertFrom-SpineMixedJsonOutput` empty catch** — mixed-stdout JSON extract
  and final throw now live inside `catch`, clearing
  `PSAvoidUsingEmptyCatchBlock` without changing parse behavior.

### Added

- **VirusTotal release URL scan (`SPA-007`)** — `.github/workflows/virustotal-release-scan.yml`
  on `release: published` (and manual dispatch); README notes `VIRUSTOTAL_API_KEY`
  secret (never commit the key).

## [0.1.2] — 2026-07-22

### Changed

- **Probe writers: `-Json` + `-AgentSummary` together** — `Write-SpineProbeResult` /
  `Write-SpineProbeEnvelope` accept `[switch] $Json`. Default and `-Json` alone still
  emit JSON only; `-AgentSummary` alone still emits summary only; both emit JSON then
  the summary line. `ConvertFrom-SpineMixedJsonOutput` falls back to object extract when
  trailing summary makes a full-string `ConvertFrom-Json` fail.

## [0.1.1] — 2026-07-17

### Added

- **Probe envelope helpers (`SPA-002`)** — `New-SpineProbeEnvelope`,
  `Write-SpineProbeEnvelope`, `Assert-SpineProbeEnvelope` (and related probe
  helpers) for the standard `{ ok, exitCode, safetyTier, summary, data }`
  contract; `ModuleVersion` `0.1.1`.
- **Dual-host CI (`SPA-004`)** — `.github/workflows/dual-host-ps.yml` (Pester
  matrix on `pwsh` + Windows PowerShell, plus PS 5.1 smoke); documented in
  `docs/consumption.md`.
- **`-AgentSummary` on smoke scripts** — `scripts/Invoke-SpinePs51SmokeTest.ps1` and
  `scripts/Test-SpineProductShellGuard.ps1` accept `-AgentSummary` and emit
  `SPINE-SMOKE-*` / `SPINE-PRODUCT-SHELLGUARD-SMOKE-*` lines for agent Shell gates.
- **Product ShellGuard pilot (`SPA-006`)** — `.cursor/hooks/` Safety-tier gate for
  agent `pwsh -File` (slim pack; not full config ShellGuard); smoke via
  `scripts/Test-SpineProductShellGuard.ps1`; documented in `docs/consumption.md`.
- **Product changelog + issue register (`SPA-005`)** — Keep a Changelog layout;
  `docs/issues.md` with stable `SPA-` identifiers cross-linked from release notes.

### Changed

- **Public-tree redaction (`SPA-003`)** — Removed private workspace vocabulary
  from module comments, tests, and docs destined for public sharing.

## [0.1.0] — 2026-07-15

### Added

- **Initial public spike (`SPA-001`)** — Runtime, Repo, Process, and Probe
  shards; MIT license; `docs/consumption.md`; Pester unit tests and PS 5.1
  smoke script.
