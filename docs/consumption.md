# Spine.Automation — consumption patterns

## Three consumers

| Consumer | Install | Invocation |
|----------|---------|------------|
| **`.cursor` config catalog** | Vendored copy under `scripts/lib/Spine.Automation/` (Phase 2) | Entry scripts stay `pwsh -NoProfile -File scripts/Invoke-*.ps1`; dot-source Private shards or `Import-Module` at script top |
| **Driver Store Manager (Intune)** | Submodule or copy in product repo; merged into bundles by build scripts | Dot-source `Spine.Runtime.ps1` from remediations on PS 5.1 endpoints |
| **Gallery / `Install-Module`** | Phase 5 — not required for config or Intune | `Install-Module Spine.Automation` when published |

## Vendoring (config Phase 2 preview)

```text
.cursor/scripts/lib/Spine.Automation/
  Private/Spine.*.ps1
  Spine.Automation.psm1   # optional; catalog may dot-source shards only
```

Catalog entry pattern:

```powershell
#Requires -Version 7.2
. (Join-Path $PSScriptRoot 'lib/Spine.Automation/Private/Spine.Runtime.ps1')
. (Join-Path $PSScriptRoot 'lib/Spine.Automation/Private/Spine.Repo.ps1')
```

Keep **one** `pwsh -NoProfile -File` Shell call per agent step — helpers live inside the script.

## Native-first

Do **not** use Spine for:

- File reads, grep, or edits → Cursor `Read` / `Grep` / `StrReplace` / `Write`
- Git status/diff/commit → allowlisted `git` one-liners
- Log table parsing or markdown line counts → existing catalog or native tools

Spine is for **shared implementation** duplicated across probes and product modules.

## Version pin

Tag **`v0.1.2`** matches `ModuleVersion` in `Spine.Automation.psd1` (probe writers
accept `-Json` and `-AgentSummary` together). Config vendoring should record the tag
in CHANGELOG when copying. **`v0.1.1`** added probe envelope helpers; **`v0.1.0`**
was the initial spike.

## Continuous integration (dual-host)

This repo ships [`.github/workflows/dual-host-ps.yml`](../.github/workflows/dual-host-ps.yml):

| Job | Host | What runs |
|-----|------|-----------|
| `pester` (matrix) | `pwsh` and `powershell` on `windows-latest` | `Invoke-Pester` against `./tests/unit` |
| `ps51-smoke` | Windows PowerShell 5.1 | `scripts/Invoke-SpinePs51SmokeTest.ps1` |

**Local dry-run** (same commands as CI, no GitHub required):

```powershell
pwsh -NoProfile -Command "Import-Module Pester -MinimumVersion 5.0.0; Invoke-Pester -Path ./tests/unit -CI"
powershell.exe -NoProfile -File ./scripts/Invoke-SpinePs51SmokeTest.ps1
```

Other dual-host product repos can copy the workflow from the Cursor config
workspace pack `templates/ps-dual-host-ci/` (or from this file) and point Pester
at their own `tests/` path.

## Product ShellGuard (optional project hooks)

User-scope Cursor hooks gate the config catalog. This repo ships a **lightweight
project pack** under `.cursor/hooks/` that only holds agent `pwsh -NoProfile
-File` when the target script lacks a declared Safety tier (or a matching
`script-safety-reviews/` seal). It does **not** copy full config ShellGuard
(file-ops allowlist, CHANGELOG roll, etc.).

| Path | Role |
|------|------|
| `.cursor/hooks.json` | `preToolUse` / `Shell` |
| `.cursor/hooks/Invoke-ProductShellGuard.ps1` | Hook entry |
| `.cursor/hooks/ProductScriptSafetyGate.Core.ps1` | Slim Safety-tier helpers |

**Local smoke:**

```powershell
pwsh -NoProfile -File ./scripts/Test-SpineProductShellGuard.ps1
```

Expect `SPINE-PRODUCT-SHELLGUARD-SMOKE-OK`. Confirm **Settings → Hooks** lists the
project entry after opening this folder. Other product repos can copy the same
layout from the config workspace pack `templates/ps-product-shellguard/`.

## License

MIT — see [LICENSE](../LICENSE).
