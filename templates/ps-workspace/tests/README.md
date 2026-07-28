# Pester tests (portable pack)

Place `*.Tests.ps1` here. Run from the repo root after copying the pack:

```powershell
Invoke-Pester -Path .\tests
```

The sample `Get-PsWorkspaceHello.Tests.ps1` covers the demo script under
`scripts/`. Replace both when the product has real behaviour under test.

For products, prefer a dedicated `tests/Invoke-<Prefix>Pester.ps1 -AgentSummary`
entry (see [`../../README.md`](../../README.md) § Validate).

*Pack: templates/ps-workspace/*
