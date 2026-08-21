#requires -Version 7.2
<#
.SYNOPSIS
  Smoke harness for product ShellGuard (stdin JSON → permission JSON).

.DESCRIPTION
  **Safety tier: 1** (read-only hook smoke; no network).

  Feeds synthetic preToolUse payloads to Invoke-ProductShellGuard.ps1 and
  asserts allow vs ask. Run from the pack root (this folder).

.EXAMPLE
  pwsh -NoProfile -File templates/ps-product-shellguard/Test-ProductShellGuard.ps1
#>
[CmdletBinding()]
param(
    [string]$HooksDir = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$packRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($HooksDir)) {
    $HooksDir = Join-Path $packRoot '.cursor\hooks'
}

$hook = Join-Path $HooksDir 'Invoke-ProductShellGuard.ps1'
if (-not (Test-Path -LiteralPath $hook)) {
    throw "Hook not found: $hook"
}

$hello = Join-Path $packRoot 'scripts\Get-ProductShellGuardHello.ps1'
$untiered = Join-Path $packRoot 'scripts\UntieredNoTier.ps1'
$pesterRunner = Join-Path $packRoot 'tests\Invoke-PackPester.ps1'
$untieredPester = Join-Path $packRoot 'tests\Invoke-UntieredPester.ps1'
$unitNotRunner = Join-Path $packRoot 'tests\unit\Dummy.Tests.ps1'

function Invoke-HookPayload {
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
            throw "Hook exited $($proc.ExitCode) for command: $Command"
        }
        return (Get-Content -LiteralPath $tmpOut -Raw)
    }
    finally {
        Remove-Item -LiteralPath $tmpIn, $tmpOut -Force -ErrorAction SilentlyContinue
    }
}

function Assert-Permission {
    param(
        [string]$Label,
        [string]$Raw,
        [string]$Expect
    )
    try { $perm = ($Raw | ConvertFrom-Json).permission }
    catch { $perm = '(parse error)' }
    if ($perm -ne $Expect) {
        throw "$Label — expect=$Expect got=$perm raw=$Raw"
    }
}

$r1 = Invoke-HookPayload -Command 'git status'
Assert-Permission -Label 'non-File Shell' -Raw $r1 -Expect 'allow'

$r2 = Invoke-HookPayload -Command "pwsh -NoProfile -File `"$hello`""
Assert-Permission -Label 'tiered scripts/ hello' -Raw $r2 -Expect 'allow'

$r3 = Invoke-HookPayload -Command "pwsh -NoProfile -File `"$untiered`""
Assert-Permission -Label 'untiered scripts/' -Raw $r3 -Expect 'ask'

$r4 = Invoke-HookPayload -Command 'pwsh -NoProfile -File ./scripts/_missing_product_shellguard.ps1'
Assert-Permission -Label 'missing path' -Raw $r4 -Expect 'ask'

$r5 = Invoke-HookPayload -Command "pwsh -NoProfile -File `"$pesterRunner`""
Assert-Permission -Label 'tiered tests/Invoke-*Pester.ps1' -Raw $r5 -Expect 'allow'

$r6 = Invoke-HookPayload -Command "pwsh -NoProfile -File `"$untieredPester`""
Assert-Permission -Label 'untiered tests/Invoke-*Pester.ps1' -Raw $r6 -Expect 'ask'

$r7 = Invoke-HookPayload -Command "pwsh -NoProfile -File `"$unitNotRunner`""
Assert-Permission -Label 'tests/unit not a Pester runner' -Raw $r7 -Expect 'ask'

Write-Output 'PRODUCT-SHELLGUARD-SMOKE-OK'
exit 0
