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

## Tests

```powershell
# PS 7+
Invoke-Pester -Path ./tests/unit/

# Windows PowerShell 5.1 smoke
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

## Design

Originated from a shared-helper overlap inventory across Cursor config catalog
scripts and product PowerShell modules. Spine holds **shared implementation** —
not replacements for Cursor `Read`/`Grep` tools or allowlisted one-liner Shell
commands.

## Related

- Probe contract (docs + Cursor plugin): [spine-cursor `spine-agent-probes`](https://github.com/villepispa/spine-cursor/tree/main/plugins/spine-agent-probes) — implement with `Write-SpineProbeResult` / envelope helpers in this module
- Sibling framework docs + Marketplace plugins: [spine-cursor](https://github.com/villepispa/spine-cursor)
- Sample PS product validate pattern: [winget-audit](https://github.com/villepispa/winget-audit)
