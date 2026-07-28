# PowerShell workspace bootstrap pack

Minimal layout for a **target** repo that already has (or will have) ad-hoc
`.ps1` scripts. Copy this folder’s contents into the repo root — do **not** copy
a full private Cursor catalog (`scripts/Invoke-*.ps1` probes, hooks, Spine shards).

**Source:** published under [spine-automation `templates/ps-workspace/`](https://github.com/villepispa/spine-automation/tree/main/templates/ps-workspace).

## What you get

| Path | Role |
|------|------|
| `scripts/` | Runnable scripts (`Verb-Noun.ps1`) |
| `scripts/_drafts/` | Ad-hoc / unvetted scripts before promotion |
| `scripts/_drafts/README.md` | Staging rules + promotion criteria (portable) |
| `scripts/Get-PsWorkspaceHello.ps1` | Example: Safety tier + StrictMode + `param()` |
| `tests/` | Pester tests beside product code |
| `tests/Get-PsWorkspaceHello.Tests.ps1` | Example test for the sample script |
| `PSScriptAnalyzerSettings.psd1` | Slim workspace PSA settings |

## Graduate to agent-ready (validate trio)

After the minimal pack exists, add the **validate** shape before treating the
tree as agent-ready (same pattern as this repo and [winget-audit](https://github.com/villepispa/winget-audit)):

| Path | Role |
|------|------|
| `scripts/Invoke-<Prefix>Validate.ps1` | Ordered orchestrator: smoke/stub → Pester → PSA; `-AgentSummary` |
| `tests/Invoke-<Prefix>Pester.ps1` | Dedicated Pester entry (`Run.PassThru` when summarizing) |
| `scripts/Invoke-<Prefix>ScriptAnalyzer.ps1` | Product PSA on `scripts/` (skip `_drafts`) + module/stubs |
| README **Validate** section | Commands + Gallery deps (`Pester`, `PSScriptAnalyzer`); README stays SSOT — no `AGENTS.md` |

Reference in this repo: `scripts/Invoke-SpineValidate.ps1`. Probe contract sibling:
[spine-cursor `spine-agent-probes`](https://github.com/villepispa/spine-cursor/tree/main/plugins/spine-agent-probes).

## Copy steps (agent or human)

1. Confirm the target repo lacks a consistent PS layout (no `scripts/` + PSA
   settings, or `.ps1` files scattered at root only).
2. Copy pack files into the **repo root** (merge; do not overwrite user scripts
   without asking). Typical destinations match the table above.
3. Rename or delete `Get-PsWorkspaceHello.ps1` / its test once you have a real
   first script — keep them as a template if useful.
4. Add a validate trio when agents need a single discovery entry (see above).

## PSA entry point

From the **target** repo root (after copy):

```powershell
Invoke-ScriptAnalyzer -Path .\scripts -Settings .\PSScriptAnalyzerSettings.psd1 -Recurse
```

Skip `_drafts/` until promotion. Prefer a product wrapper
`scripts/Invoke-<Prefix>ScriptAnalyzer.ps1` once you graduate to the validate
trio.

## Pester entry point

```powershell
Invoke-Pester -Path .\tests
```

For products, prefer `tests/Invoke-<Prefix>Pester.ps1 -AgentSummary`.
**Pester 6:** set `$config.Run.PassThru = $true` when the caller needs counts
for `-AgentSummary`.

## Hard rules for this pack

- **No secrets**, tokens, or machine-specific absolute paths in committed scripts.
- Every agent-created/updated `.ps1`: `**Safety tier: N**` as the first
  `.DESCRIPTION` line, blank help line, then synopsis body.
- Prefer `param()`, `Set-StrictMode`, and `$ErrorActionPreference = 'Stop'`.
- Stage one-offs under `scripts/_drafts/`; promote only with tests + tier.

## See also

- Dual-host CI pack: [`../ps-dual-host-ci/`](../ps-dual-host-ci/)
- Product ShellGuard pack: [`../ps-product-shellguard/`](../ps-product-shellguard/)
- Sample validate: [winget-audit](https://github.com/villepispa/winget-audit)
