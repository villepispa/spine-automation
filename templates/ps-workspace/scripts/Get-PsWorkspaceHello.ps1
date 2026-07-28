#requires -Version 7.2
<#
.SYNOPSIS
  Emit a one-line hello JSON object for the portable PS workspace pack demo.

.DESCRIPTION
  **Safety tier: 1** (read-only).

  Example script shipped with templates/ps-workspace/. Replace or delete after
  the repo has a real first script. Demonstrates Safety tier, param(),
  StrictMode, and ErrorActionPreference — no absolute paths.

.PARAMETER Name
  Display name included in the greeting. Default: Workspace.

.EXAMPLE
  pwsh -NoProfile -File scripts/Get-PsWorkspaceHello.ps1

.EXAMPLE
  pwsh -NoProfile -File scripts/Get-PsWorkspaceHello.ps1 -Name Demo

.OUTPUTS
  JSON object: { ok, greeting, name }.

.NOTES
  Pack: templates/ps-workspace/README.md
#>
[CmdletBinding()]
param(
    [string] $Name = 'Workspace'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$result = [ordered]@{
    ok       = $true
    greeting = "Hello from $Name"
    name     = $Name
}

# Always JSON for this demo so agents get a stable envelope shape.
$result | ConvertTo-Json -Compress
exit 0
