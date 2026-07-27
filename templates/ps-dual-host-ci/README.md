# Dual-host PowerShell — GitHub Actions matrix

Reusable **Windows** workflow that runs the same Pester suite under **`pwsh`**
(PowerShell 7+) and **`powershell`** (Windows PowerShell 5.1), plus a dedicated
PS 5.1 smoke job. Shared QA language for product repos that target Intune or
other dual-host modules (including Spine.Automation consumers).

| File | Role |
|------|------|
| [`dual-host-ps.yml`](dual-host-ps.yml) | Copy to `.github/workflows/dual-host-ps.yml` |

**Live pilot in this repo:** [`.github/workflows/dual-host-ps.yml`](../../.github/workflows/dual-host-ps.yml)
(Pester under `./tests/unit` + `scripts/Invoke-SpinePs51SmokeTest.ps1`).

## Prerequisites

- Repo has (or will have) Pester tests under `tests/` (or edit the workflow path)
- GitHub Actions enabled on the repo (or use the dry-run below until the first push)
- Optional: a PS 5.1 smoke script; default template asserts the 5.1 host and runs
  `scripts/Invoke-Ps51SmokeTest.ps1` when present

## Install

1. Create `.github/workflows/` in the **target** repo root if missing.
2. Copy `dual-host-ps.yml` into that folder.
3. Adjust paths in the workflow comments:
   - Pester path (`./tests` vs `./tests/unit`)
   - Smoke script name (this repo uses `Invoke-SpinePs51SmokeTest.ps1`)
4. Commit and push; open **Actions** to confirm both matrix shells + smoke are green.

Do **not** commit tokens, personal absolute paths, or private lab backlog IDs
into the workflow file.

## Customize

| Knob | Where |
|------|--------|
| Trigger branches | `on.push.branches` |
| Pester path / config | `pester` job step `Run Pester` |
| Skip 5.1 smoke | Remove or `if: false` the `ps51-smoke` job |

## Documented dry-run (no GitHub required)

```powershell
pwsh -NoProfile -Command "Import-Module Pester -MinimumVersion 5.0.0; Invoke-Pester -Path ./tests -CI"
powershell.exe -NoProfile -Command "Import-Module Pester -MinimumVersion 5.0.0; Invoke-Pester -Path ./tests -CI"
powershell.exe -NoProfile -File ./scripts/Invoke-Ps51SmokeTest.ps1
```

**This repo:**

```powershell
pwsh -NoProfile -Command "Import-Module Pester -MinimumVersion 5.0.0; Invoke-Pester -Path ./tests/unit -CI"
powershell.exe -NoProfile -File ./scripts/Invoke-SpinePs51SmokeTest.ps1
```

## Related

- Consumption notes: [docs/consumption.md](../../docs/consumption.md)
- Product ShellGuard pack: [`../ps-product-shellguard/`](../ps-product-shellguard/)
- Probe contract plugin: [spine-cursor `spine-agent-probes`](https://github.com/villepispa/spine-cursor/tree/main/plugins/spine-agent-probes)
