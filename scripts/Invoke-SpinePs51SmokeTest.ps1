#Requires -Version 5.1
<#
.SYNOPSIS
  PS 5.1 smoke test for Spine.Automation module load and core helpers.

.DESCRIPTION
  **Safety tier: 1** (read-only smoke; writes temp file only).

  Run under Windows PowerShell 5.1:
    powershell.exe -NoProfile -File ./scripts/Invoke-SpinePs51SmokeTest.ps1

.PARAMETER AgentSummary
  Write exactly one line to the success stream so agents can use a single
  pwsh/powershell -NoProfile -File invocation (no Shell compound with
  if ($LASTEXITCODE)): SPINE-SMOKE-OK on exit 0; SMOKE-SKIP when not
  PS 5.1; SPINE-SMOKE-FAIL exit=N on failure.
#>
[CmdletBinding()]
param(
    [switch] $AgentSummary
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-SpineSmokeExit {
    param(
        [int] $ExitCode,
        [string] $SummaryLine
    )
    if ($AgentSummary) {
        Write-Output $SummaryLine
    }
    elseif ($ExitCode -eq 0) {
        # Preserve legacy stdout for humans / callers that omit -AgentSummary.
        Write-Output $SummaryLine
    }
    exit $ExitCode
}

try {
    $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    $moduleRoot = Join-Path $repoRoot 'src\Spine.Automation'
    Import-Module (Join-Path $moduleRoot 'Spine.Automation.psd1') -Force

    if (-not (Test-SpineIsWindowsPowerShell51)) {
        Invoke-SpineSmokeExit -ExitCode 0 -SummaryLine 'SMOKE-SKIP not PS 5.1 host'
    }

    $joined = Join-SpinePath $env:TEMP 'SpineSmoke' 'out.txt'
    if ($joined -notlike '*SpineSmoke*') {
        throw 'Join-SpinePath failed'
    }

    $fixtureRoot = Join-Path $repoRoot 'tests\fixtures\mini-repo'
    $found = Find-SpineRepoRoot -StartDir (Join-Path $fixtureRoot 'nested')
    if ($found -ne $fixtureRoot) {
        throw "Find-SpineRepoRoot expected $fixtureRoot got $found"
    }

    $tempFile = Join-Path $env:TEMP ("spine-smoke-{0}.txt" -f [Guid]::NewGuid().ToString('N'))
    try {
        Set-SpineContentUtf8 -LiteralPath $tempFile -Value 'smoke'
        $bytes = [System.IO.File]::ReadAllBytes($tempFile)
        if ($bytes.Length -ne 5) {
            throw 'UTF-8 write length mismatch'
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempFile) {
            Remove-Item -LiteralPath $tempFile -Force
        }
    }

    Invoke-SpineSmokeExit -ExitCode 0 -SummaryLine 'SPINE-SMOKE-OK'
}
catch {
    $msg = $_.Exception.Message
    if ($AgentSummary) {
        Write-Output ("SPINE-SMOKE-FAIL exit=1 detail={0}" -f ($msg -replace '\s+', ' '))
        exit 1
    }
    throw
}
