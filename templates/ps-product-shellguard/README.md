# Lightweight product ShellGuard pack

Optional **project** hooks for OSS / dual-host PowerShell product repos.
Enforces **Safety tier parse** on agent `pwsh -NoProfile -File` only — not a
full user-scope ShellGuard (file-ops NEVER table, `git -C`, machine allowlists,
CHANGELOG roll).

**Why:** User hooks under `~/.cursor` gate a private config catalog. Product
trees stay silent unless the repo adds project hooks.

| Path | Role |
|------|------|
| [`.cursor/hooks.json`](.cursor/hooks.json) | `preToolUse` / `Shell` → product hook |
| [`.cursor/hooks/Invoke-ProductShellGuard.ps1`](.cursor/hooks/Invoke-ProductShellGuard.ps1) | stdin JSON → allow / ask |
| [`.cursor/hooks/ProductScriptSafetyGate.Core.ps1`](.cursor/hooks/ProductScriptSafetyGate.Core.ps1) | Slim Core (no Spine import) |
| [`scripts/Get-ProductShellGuardHello.ps1`](scripts/Get-ProductShellGuardHello.ps1) | Tiered smoke fixture |
| [`scripts/UntieredNoTier.ps1`](scripts/UntieredNoTier.ps1) | Untiered HOLD fixture |
| [`Test-ProductShellGuard.ps1`](Test-ProductShellGuard.ps1) | Dry-run harness |

## Design

| Concern | Behaviour |
|---------|-----------|
| **Repo root** | Walk up for `.cursor/hooks.json` or `.git` |
| **Catalog paths** | `scripts/**/*.ps1`, `hooks/**/*.ps1`, `.cursor/hooks/**/*.ps1` |
| **Draft** | Paths under `_drafts` / `_archive` → effective Tier 3 |
| **External** | Other paths without a matching `script-safety-reviews/` seal → HOLD |
| **Task profile** | Agent Shell uses `ControlledWrite` (max tier 2) |
| **failClosed** | `false` — parse errors allow |
| **Non-File Shell** | Always allow (no file-ops pattern table) |

Optional seals: place JSON under product `script-safety-reviews/` with
`scriptPath` (repo-relative), `sha256`, and `approvedTaskProfiles`.

## Install

1. Copy `.cursor/hooks.json` and `.cursor/hooks/*.ps1` into the **product** repo
   root (merge `preToolUse` entries if hooks already exist).
2. Ensure product scripts under `scripts/` declare `**Safety tier: N**` in
   comment help.
3. Open the product folder and confirm **Settings → Hooks** lists the project
   entry.
4. Optional: add `script-safety-reviews/` seals for untiered third-party scripts.

Do **not** copy a full private config ShellGuard or machine `permissions.json`
into product trees.

## Smoke

From this pack folder:

```powershell
pwsh -NoProfile -File ./Test-ProductShellGuard.ps1
```

Expect `PRODUCT-SHELLGUARD-SMOKE-OK`.

This repo also ships the same hooks live under `.cursor/hooks/` and
`scripts/Test-SpineProductShellGuard.ps1` (see [docs/consumption.md](../../docs/consumption.md)).

## Related

- Probe contract (docs/skill): [spine-cursor `spine-agent-probes`](https://github.com/villepispa/spine-cursor/tree/main/plugins/spine-agent-probes)
- Dual-host CI template: [`../ps-dual-host-ci/`](../ps-dual-host-ci/)
- Sibling product: [spine-cursor](https://github.com/villepispa/spine-cursor)
