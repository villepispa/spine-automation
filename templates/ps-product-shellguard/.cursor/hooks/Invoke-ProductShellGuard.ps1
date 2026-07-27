#requires -Version 7.2
<#
.SYNOPSIS
  Project preToolUse hook — Safety tier gate for pwsh -File only.

.DESCRIPTION
  **Safety tier: 1** (read-only Shell command policy check; stdin JSON hook).

  Lightweight product ShellGuard: does **not** enforce config-repo file-ops
  NEVER patterns, git -C, permissions.json, or CHANGELOG roll. Only holds when
  the pending Shell command runs pwsh -File against a script that fails the
  product Safety-tier gate (see ProductScriptSafetyGate.Core.ps1).

  Wire via .cursor/hooks.json (failClosed: false). Fails open on parse errors.

.NOTES
  Hook event : preToolUse (matcher Shell)
  Pack       : templates/ps-product-shellguard/
#>

param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProductScriptSafetyGate.Core.ps1')

$raw = [System.Console]::In.ReadToEnd()

try {
    $payload = $raw | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Output '{"permission":"allow"}'
    exit 0
}

$cmd = ''
if ($payload.PSObject.Properties['input'] -and
    $payload.input -is [pscustomobject] -and
    $payload.input.PSObject.Properties['command']) {
    $cmd = [string]$payload.input.command
}
if (-not $cmd -and $payload.PSObject.Properties['command']) {
    $cmd = [string]$payload.command
}
if (-not $cmd -and $payload.PSObject.Properties['toolInput'] -and
    $payload.toolInput -is [pscustomobject] -and
    $payload.toolInput.PSObject.Properties['command']) {
    $cmd = [string]$payload.toolInput.command
}
if ($cmd) {
    $cmd = $cmd.TrimStart([char]0xFEFF)
}

if (-not $cmd) {
    Write-Output '{"permission":"allow"}'
    exit 0
}

$scriptTarget = Get-ProductPwshFileScriptPathFromCommand -Command $cmd
if (-not $scriptTarget) {
    # Non-File Shell (including file-ops patterns) — allow; product pack is tier-only.
    Write-Output '{"permission":"allow"}'
    exit 0
}

$repoRoot = Find-ProductRepoRoot -StartDir $PSScriptRoot
if (-not $repoRoot) {
    $repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$gate = Test-ProductScriptSafetyGate `
    -ScriptPath $scriptTarget `
    -RepoRoot $repoRoot `
    -TaskProfile 'ControlledWrite' `
    -ArgumentString $cmd

if ($gate.decision -eq 'allow') {
    Write-Output '{"permission":"allow"}'
    exit 0
}

$userMsg = @(
    'Product ShellGuard — HOLD before running this script:'
    "  Script: $($gate.scriptPathRel)"
    "  SHA-256: $($gate.sha256)"
    "  $($gate.reason)"
    ''
    'Add **Safety tier: N** to comment help, or place a seal under script-safety-reviews/.'
    'This pack does not enforce config-repo file-ops allowlist rules.'
) -join "`n"

$agentMsg = "ProductShellGuard HOLD: $($gate.reason)"

$out = [ordered]@{
    permission    = 'ask'
    user_message  = $userMsg
    agent_message = $agentMsg
}
Write-Output ($out | ConvertTo-Json -Compress)
exit 0
