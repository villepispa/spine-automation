#requires -Version 7.2
<#
.SYNOPSIS
  Slim Safety-tier helpers for product ShellGuard (no config allowlist).

.DESCRIPTION
  **Safety tier: 1** (read-only classification; no writes).

  Product fork of ScriptSafetyGate.Core behaviour: find product repo root,
  classify scripts/hooks paths, parse **Safety tier:**, consult local
  script-safety-reviews/ seals. Does not import Spine or config catalog paths.

  Dot-source from Invoke-ProductShellGuard.ps1 in the same folder.

.NOTES
  Pack: templates/ps-product-shellguard/
#>
Set-StrictMode -Version 3
$ErrorActionPreference = 'Stop'

$script:SafetyTierPattern = '(?m)\*\*Safety tier:\s*([123])\*\*'
$script:Tier2ArgPattern = '(?i)(-CheckGitHub|-OutTextPath|-OutPath|-OutMmdPath|-UpdateBaseline|-ArchiveDriftReports|-Unregister|-WhatIf:\$false)'

function Find-ProductRepoRoot {
    param([string]$StartDir)
    $dir = if ([string]::IsNullOrWhiteSpace($StartDir)) {
        (Get-Location).Path
    }
    else {
        $StartDir
    }
    while ($dir) {
        $hooksJson = Join-Path $dir '.cursor\hooks.json'
        $gitDir = Join-Path $dir '.git'
        if ((Test-Path -LiteralPath $hooksJson) -or (Test-Path -LiteralPath $gitDir)) {
            return $dir
        }
        $parent = Split-Path -Parent $dir
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

function Resolve-ProductScriptSafetyPath {
    param(
        [string]$ScriptPath,
        [string]$RepoRoot
    )
    if ([string]::IsNullOrWhiteSpace($ScriptPath)) { return $null }
    $p = $ScriptPath.Trim().Trim('"', "'")
    if (-not [System.IO.Path]::IsPathRooted($p) -and $RepoRoot) {
        $p = Join-Path $RepoRoot $p
    }
    try { return (Resolve-Path -LiteralPath $p -ErrorAction Stop).Path }
    catch { return $null }
}

function Get-ProductScriptDeclaredTier {
    param([string]$ScriptPath)
    $head = @(Get-Content -LiteralPath $ScriptPath -TotalCount 120 -ErrorAction Stop)
    $tierMatches = [regex]::Matches(($head -join "`n"), $script:SafetyTierPattern)
    @($tierMatches | ForEach-Object { [int]$_.Groups[1].Value } | Sort-Object -Unique)
}

function Get-ProductScriptSafetyClassification {
    param(
        [string]$ResolvedPath,
        [string]$RepoRoot
    )
    if (-not $RepoRoot) { return 'external' }
    $rel = try {
        [System.IO.Path]::GetRelativePath($RepoRoot, $ResolvedPath).Replace('\', '/')
    }
    catch { return 'external' }

    if ($rel -match '(^|/)(_drafts|_archive)(/|$)') { return 'draft' }
    if ($rel -match '^(scripts|hooks)/.+\.ps1$') { return 'catalog' }
    if ($rel -match '^\.cursor/hooks/.+\.ps1$') { return 'catalog' }
    if ($rel -match '^tests/Invoke-[^/]+Pester\.ps1$') { return 'catalog' }
    return 'external'
}

function Get-ProductScriptEffectiveTier {
    param(
        [string[]]$DeclaredTiers,
        [string]$Classification,
        [string]$ArgumentString
    )
    if ($Classification -in @('external', 'draft')) { return 3 }
    if (-not $DeclaredTiers -or $DeclaredTiers.Count -eq 0) { return 3 }

    $maxDeclared = ($DeclaredTiers | Measure-Object -Maximum).Maximum
    if ($maxDeclared -eq 1) { return 1 }
    if ($ArgumentString -and ($ArgumentString -match $script:Tier2ArgPattern)) {
        return [Math]::Max(2, $maxDeclared)
    }
    if ($DeclaredTiers -contains 1 -and $DeclaredTiers.Count -eq 1) { return 1 }
    if ($DeclaredTiers -contains 1) { return 1 }
    return $maxDeclared
}

function Get-ProductTaskProfileMaxTier {
    param([string]$TaskProfile)
    switch ($TaskProfile) {
        'ReadOnly' { return 1 }
        'ControlledWrite' { return 2 }
        'Network' { return 2 }
        default { return 1 }
    }
}

function Get-ProductScriptSafetyReviewSeal {
    param(
        [string]$RepoRoot,
        [string]$ScriptPathRel,
        [string]$Sha256
    )
    $reviewDir = Join-Path $RepoRoot 'script-safety-reviews'
    if (-not (Test-Path -LiteralPath $reviewDir)) { return $null }

    $candidates = @(
        Get-ChildItem -LiteralPath $reviewDir -Filter '*.json' -File -ErrorAction SilentlyContinue
    )
    foreach ($file in $candidates) {
        try {
            $seal = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8 | ConvertFrom-Json
        }
        catch { continue }
        if ($seal.scriptPath -ne $ScriptPathRel) { continue }
        if ($seal.sha256 -ne $Sha256) { continue }
        return [pscustomobject]@{
            path = $file.FullName
            seal = $seal
        }
    }
    return $null
}

function Test-ProductScriptSafetyGate {
    param(
        [string]$ScriptPath,
        [string]$RepoRoot,
        [string]$TaskProfile = 'ControlledWrite',
        [string]$ArgumentString = ''
    )

    $resolved = Resolve-ProductScriptSafetyPath -ScriptPath $ScriptPath -RepoRoot $RepoRoot
    if (-not $resolved) {
        return [pscustomobject]@{
            decision       = 'hold'
            reason         = "Script path not found: $ScriptPath"
            scriptPath     = $ScriptPath
            scriptPathRel  = $null
            sha256         = $null
            declaredTiers  = @()
            effectiveTier = 3
            classification = 'external'
            taskProfile    = $TaskProfile
            reviewSeal     = $null
        }
    }

    $hash = (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash.ToLowerInvariant()
    $rel = if ($RepoRoot) {
        try { [System.IO.Path]::GetRelativePath($RepoRoot, $resolved).Replace('\', '/') }
        catch { $resolved }
    }
    else { $resolved }

    $declared = @(Get-ProductScriptDeclaredTier -ScriptPath $resolved)
    $class = Get-ProductScriptSafetyClassification -ResolvedPath $resolved -RepoRoot $RepoRoot
    $effective = Get-ProductScriptEffectiveTier -DeclaredTiers $declared -Classification $class -ArgumentString $ArgumentString
    $maxAllowed = Get-ProductTaskProfileMaxTier -TaskProfile $TaskProfile
    $sealHit = if ($RepoRoot) {
        Get-ProductScriptSafetyReviewSeal -RepoRoot $RepoRoot -ScriptPathRel $rel -Sha256 $hash
    }
    else { $null }

    $reason = $null
    $decision = 'allow'

    if ($sealHit -and $sealHit.seal.approvedTaskProfiles -contains $TaskProfile) {
        $reason = "Review seal OK ($($sealHit.seal.reviewedBy) $($sealHit.seal.reviewedUtc))."
        $decision = 'allow'
    }
    elseif ($effective -gt $maxAllowed) {
        $decision = 'hold'
        if ($class -eq 'external' -and (-not $declared -or $declared.Count -eq 0)) {
            $reason = 'No **Safety tier:** in comment help — treat as external Tier 3; add Safety tier or product script-safety-reviews seal.'
        }
        elseif ($class -eq 'draft') {
            $reason = 'Script is under scripts/_drafts or _archive — promote or seal before production use.'
        }
        else {
            $reason = "Effective tier $effective exceeds task profile $TaskProfile (max $maxAllowed)."
        }
    }
    elseif ($class -eq 'external' -and (-not $declared -or $declared.Count -eq 0)) {
        $decision = 'hold'
        $reason = 'External script without documented tier — add **Safety tier:** or a product review seal.'
    }
    else {
        $reason = "Product catalog script; effective tier $effective within $TaskProfile (max $maxAllowed)."
    }

    [pscustomobject]@{
        decision       = $decision
        reason         = $reason
        scriptPath     = $resolved
        scriptPathRel  = $rel
        sha256         = $hash
        declaredTiers  = $declared
        effectiveTier  = $effective
        classification = $class
        taskProfile    = $TaskProfile
        reviewSeal     = if ($sealHit) {
            [pscustomobject]@{
                path                  = $sealHit.path
                reviewedBy            = $sealHit.seal.reviewedBy
                reviewedUtc           = $sealHit.seal.reviewedUtc
                approvedTaskProfiles  = @($sealHit.seal.approvedTaskProfiles)
            }
        }
        else { $null }
    }
}

function Get-ProductPwshFileScriptPathFromCommand {
    param([string]$Command)
    if ([string]::IsNullOrWhiteSpace($Command)) { return $null }
    $m = [regex]::Match($Command, '(?i)pwsh(?:\.exe)?\s+(?:[^\s|;&]+?\s+)*-File\s+(?<q>''[^'']+''|"[^"]+"|[^\s|;&]+)')
    if (-not $m.Success) { return $null }
    return $m.Groups['q'].Value.Trim().Trim('"', "'")
}
