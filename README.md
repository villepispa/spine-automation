# Spine.Automation

Shared PowerShell primitives for Cursor config catalog scripts, security
product modules (Driver Store Manager), and other dual-host tooling.

**Module:** `Spine.Automation`  
**Floor:** PowerShell 5.1+ (Windows PowerShell and PowerShell 7)

## Quick start

```powershell
Import-Module ./src/Spine.Automation/Spine.Automation.psd1 -Force
Join-SpinePath $env:TEMP 'reports' 'baseline.json'
```

## Validate (agents / CI discovery)

Single entry: PS 5.1 smoke → Pester → product PSScriptAnalyzer.

**Gallery deps** (CurrentUser; validate does not auto-install):

```powershell
Install-Module Pester -MinimumVersion 5.5.0 -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -SkipPublisherCheck
```

```powershell
pwsh -NoProfile -File .\scripts\Invoke-SpineValidate.ps1 -AgentSummary
# Success line: SPINE-VALIDATE-OK
# PSA-less host: add -SkipLint
```

Optional Task palette (needs `CURSOR_CONFIG_ROOT`): `.vscode/tasks.json`.

Stage runners (same tokens as winget-audit-shaped products):

| Stage | Script |
|-------|--------|
| Smoke | `scripts/Invoke-SpinePs51SmokeTest.ps1` (via `powershell.exe`) |
| Pester | `tests/Invoke-SpinePester.ps1` |
| Lint | `scripts/Invoke-SpineScriptAnalyzer.ps1` + `PSScriptAnalyzerSettings.psd1` |

## Tests

```powershell
# Preferred agent entry (above), or:
Invoke-Pester -Path ./tests/unit/
powershell.exe -NoProfile -File ./scripts/Invoke-SpinePs51SmokeTest.ps1
```

**CI:** [`.github/workflows/dual-host-ps.yml`](.github/workflows/dual-host-ps.yml) runs
Pester under both `pwsh` and Windows PowerShell, plus the 5.1 smoke script.
Dry-run and install notes: [docs/consumption.md](docs/consumption.md) § Continuous
integration.

**Release scan:** [`.github/workflows/virustotal-release-scan.yml`](.github/workflows/virustotal-release-scan.yml)
submits release download URLs to VirusTotal on `release: published`. Set repository
secret `VIRUSTOTAL_API_KEY` once (never commit the key).

## Consumption

See [docs/consumption.md](docs/consumption.md).

## Documentation

- [CHANGELOG.md](CHANGELOG.md)
- [docs/issues.md](docs/issues.md)
- [docs/consumption.md](docs/consumption.md)

## Templates (copy into other product repos)

| Pack | Role |
|------|------|
| [`templates/ps-dual-host-ci/`](templates/ps-dual-host-ci/) | Dual-host Pester + PS 5.1 smoke GitHub Actions workflow |
| [`templates/ps-product-shellguard/`](templates/ps-product-shellguard/) | Lightweight project hooks (Safety tier on `pwsh -File`) |
| [`templates/ps-workspace/`](templates/ps-workspace/) | Minimal `scripts/` + `tests/` + PSA settings bootstrap for new PS repos |

## Design

Originated from a shared-helper overlap inventory across Cursor config catalog
scripts and product PowerShell modules. Spine holds **shared implementation** —
not replacements for Cursor `Read`/`Grep` tools or allowlisted one-liner Shell
commands.

## Related

- Probe contract (docs + Cursor plugin): [spine-cursor `spine-agent-probes`](https://github.com/villepispa/spine-cursor/tree/main/plugins/spine-agent-probes) — implement with `Write-SpineProbeResult` / envelope helpers in this module
- Sibling framework docs + Marketplace plugins: [spine-cursor](https://github.com/villepispa/spine-cursor)
- Consumer product module: [driver-store-manager](https://github.com/villepispa/driver-store-manager)
- Sample PS product validate pattern: [winget-audit](https://github.com/villepispa/winget-audit)
