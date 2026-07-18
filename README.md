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

## Consumption

See [docs/consumption.md](docs/consumption.md).

## Documentation

- [CHANGELOG.md](CHANGELOG.md)
- [docs/issues.md](docs/issues.md)
- [docs/consumption.md](docs/consumption.md)

## Design

Originated from a shared-helper overlap inventory across Cursor config catalog
scripts and product PowerShell modules. Spine holds **shared implementation** —
not replacements for Cursor `Read`/`Grep` tools or allowlisted one-liner Shell
commands.
