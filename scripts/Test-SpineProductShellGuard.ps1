#Requires -Version 7.2
<#
.SYNOPSIS
  Smoke product ShellGuard pilot hooks in this repo.

.DESCRIPTION
  **Safety tier: 1** (read-only hook smoke; temp files only).

  Asserts .cursor/hooks/Invoke-ProductShellGuard.ps1 allows non-File Shell and
  allows pwsh -File on scripts/Invoke-SpinePs51SmokeTest.ps1.

.PARAMETER AgentSummary
  Write exactly one line to the success stream so agents can use a single
  pwsh -NoProfile -File invocation (no Shell compound with if ($LASTEXITCODE)):
  SPINE-PRODUCT-SHELLGUARD-SMOKE-OK on exit 0;
  SPINE-PRODUCT-SHELLGUARD-SMOKE-FAIL exit=N on failure.
#>
[CmdletBinding()]
param(
    [switch] $AgentSummary
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $hook = Join-Path $repoRoot '.cursor\hooks\Invoke-ProductShellGuard.ps1'
    $smoke = Join-Path $PSScriptRoot 'Invoke-SpinePs51SmokeTest.ps1'

    if (-not (Test-Path -LiteralPath $hook)) {
        throw "Product ShellGuard hook missing: $hook"
    }

    function Invoke-ProductHookPermission {
        param([string]$Command)
        $payload = '{"input":{"command":' + ($Command | ConvertTo-Json -Compress) + '}}'
        $tmpIn = [System.IO.Path]::GetTempFileName()
        $tmpOut = [System.IO.Path]::GetTempFileName()
        try {
            Set-Content -LiteralPath $tmpIn -Value $payload -NoNewline -Encoding utf8
            $proc = Start-Process pwsh `
                -ArgumentList "-NoProfile -File `"$hook`"" `
                -RedirectStandardInput $tmpIn `
                -RedirectStandardOutput $tmpOut `
                -NoNewWindow -Wait -PassThru
            if ($proc.ExitCode -ne 0) {
                throw "Hook exited $($proc.ExitCode)"
            }
            $raw = Get-Content -LiteralPath $tmpOut -Raw
            return ($raw | ConvertFrom-Json).permission
        }
        finally {
            Remove-Item -LiteralPath $tmpIn, $tmpOut -Force -ErrorAction SilentlyContinue
        }
    }

    $p1 = Invoke-ProductHookPermission -Command 'git status'
    if ($p1 -ne 'allow') { throw "Expected allow for git status; got $p1" }

    $p2 = Invoke-ProductHookPermission -Command "pwsh -NoProfile -File `"$smoke`""
    if ($p2 -ne 'allow') { throw "Expected allow for tiered smoke script; got $p2" }

    Write-Output 'SPINE-PRODUCT-SHELLGUARD-SMOKE-OK'
    exit 0
}
catch {
    if ($AgentSummary) {
        $msg = $_.Exception.Message -replace '\s+', ' '
        Write-Output ("SPINE-PRODUCT-SHELLGUARD-SMOKE-FAIL exit=1 detail={0}" -f $msg)
        exit 1
    }
    throw
}
