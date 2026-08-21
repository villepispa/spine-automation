function Write-SpineProbeResult {
    <#
    .SYNOPSIS
        Writes probe stdout as JSON and/or a single AgentSummary line.
    .PARAMETER Payload
        Object serialized when JSON is emitted (default, or with -Json).
    .PARAMETER Json
        Emit JSON for Payload. Combine with -AgentSummary for mixed stdout
        (JSON then summary). Alone (or with neither switch) emits JSON only.
    .PARAMETER AgentSummary
        Emit SummaryLine after JSON when -Json is also set; summary only when
        -Json is off (backward compatible).
    .PARAMETER SummaryLine
        One-line summary when -AgentSummary is set (caller builds tag/exit detail).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object] $Payload,

        [switch] $Json,

        [switch] $AgentSummary,

        [string] $SummaryLine,

        [int] $Depth = 10
    )

    $emitJson = $Json -or -not $AgentSummary
    $emitSummary = $AgentSummary

    if ($emitJson) {
        $Payload | ConvertTo-Json -Depth $Depth
    }
    if ($emitSummary -and -not [string]::IsNullOrWhiteSpace($SummaryLine)) {
        Write-Output $SummaryLine
    }
}

function New-SpineProbeEnvelope {
    <#
    .SYNOPSIS
        Builds the standard probe envelope object (does not write stdout).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Data,

        [int] $ExitCode = 0,

        [int] $SafetyTier = 1,

        [string] $Summary = '',

        [string] $CriteriaHash,

        [string] $ContractId
    )

    $envelope = [pscustomobject]@{
        ok         = ($ExitCode -eq 0)
        exitCode   = $ExitCode
        safetyTier = $SafetyTier
        summary    = $Summary
        data       = $Data
    }

    if (-not [string]::IsNullOrWhiteSpace($CriteriaHash)) {
        $envelope | Add-Member -NotePropertyName 'criteriaHash' -NotePropertyValue $CriteriaHash.Trim().ToLowerInvariant()
    }
    if (-not [string]::IsNullOrWhiteSpace($ContractId)) {
        $envelope | Add-Member -NotePropertyName 'contractId' -NotePropertyValue $ContractId.Trim()
    }

    return $envelope
}

function Write-SpineProbeEnvelope {
    <#
    .SYNOPSIS
        Writes a standard probe envelope as JSON and/or an AgentSummary line.
    .DESCRIPTION
        Builds { ok, exitCode, safetyTier, summary, data } plus optional
        criteriaHash / contractId, then routes through Write-SpineProbeResult.
        When -AgentSummary is set without -SummaryLine, emits PROBE-OK /
        PROBE-FAIL exit=N from ExitCode. -Json with -AgentSummary emits
        envelope JSON then the summary line (mixed stdout). The envelope is
        evidence, not an accept.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Data,

        [int] $ExitCode = 0,

        [int] $SafetyTier = 1,

        [string] $Summary = '',

        [string] $CriteriaHash,

        [string] $ContractId,

        [switch] $Json,

        [switch] $AgentSummary,

        [string] $SummaryLine,

        [int] $Depth = 10
    )

    $envelope = New-SpineProbeEnvelope -Data $Data -ExitCode $ExitCode -SafetyTier $SafetyTier -Summary $Summary -CriteriaHash $CriteriaHash -ContractId $ContractId

    $line = $SummaryLine
    if ($AgentSummary -and [string]::IsNullOrWhiteSpace($line)) {
        if (-not [string]::IsNullOrWhiteSpace($Summary)) {
            $line = $Summary
        }
        elseif ($ExitCode -eq 0) {
            $line = 'PROBE-OK exit=0'
        }
        else {
            $line = "PROBE-FAIL exit=$ExitCode"
        }
    }

    Write-SpineProbeResult -Payload $envelope -Json:$Json -AgentSummary:$AgentSummary -SummaryLine $line -Depth $Depth
}

function Assert-SpineProbeEnvelope {
    <#
    .SYNOPSIS
        Validates a standard probe envelope (required keys + ok/exitCode consistency).
    .DESCRIPTION
        Throws on failure — intended for Pester and catalog smoke checks.
        Optional criteriaHash, when present, must be 64-char lowercase SHA-256
        hex. Optional contractId, when present, must be non-empty.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object] $Envelope
    )

    $required = @('ok', 'exitCode', 'safetyTier', 'summary', 'data')
    $names = @($Envelope.PSObject.Properties.Name)
    foreach ($key in $required) {
        if ($names -notcontains $key) {
            throw "Probe envelope missing required key: $key"
        }
    }

    $ok = [bool]$Envelope.ok
    $code = [int]$Envelope.exitCode
    if ($ok -ne ($code -eq 0)) {
        throw "Probe envelope ok=$ok inconsistent with exitCode=$code"
    }

    $hash = Get-SpineObjectPropertyValue -Object $Envelope -Name 'criteriaHash'
    if ($null -ne $hash -and -not [string]::IsNullOrWhiteSpace([string]$hash)) {
        if ([string]$hash -cnotmatch '^[0-9a-f]{64}$') {
            throw 'Probe envelope criteriaHash must be 64-char lowercase SHA-256 hex'
        }
    }

    $cid = Get-SpineObjectPropertyValue -Object $Envelope -Name 'contractId'
    if ($null -ne $cid -and [string]::IsNullOrWhiteSpace([string]$cid)) {
        throw 'Probe envelope contractId must be a non-empty string when present'
    }
}

function Get-SpineCriteriaHash {
    <#
    .SYNOPSIS
        SHA-256 (lowercase hex) of done-criteria text or a UTF-8 file.
    .DESCRIPTION
        Bind probe evidence to a criteria version. Hash UTF-8 bytes with no BOM.
        Pair with New-SpineProbeEnvelope -CriteriaHash and
        Test-SpineProbeCriteriaBinding. Dual-host: SHA256.Create (Windows
        PowerShell 5.1 and PowerShell 7+).
    #>
    [CmdletBinding(DefaultParameterSetName = 'Text')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Text')]
        [AllowEmptyString()]
        [string] $Text,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string] $LiteralPath
    )

    if ($PSCmdlet.ParameterSetName -eq 'Path') {
        if (-not (Test-Path -LiteralPath $LiteralPath)) {
            throw "Criteria path not found: $LiteralPath"
        }

        $utf8 = [System.Text.UTF8Encoding]::new($false)
        $Text = [System.IO.File]::ReadAllText($LiteralPath, $utf8)
    }

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $hashBytes = $sha.ComputeHash($bytes)
        $builder = [System.Text.StringBuilder]::new(64)
        foreach ($b in $hashBytes) {
            [void]$builder.Append($b.ToString('x2'))
        }

        return $builder.ToString()
    }
    finally {
        $sha.Dispose()
    }
}

function Test-SpineProbeCriteriaBinding {
    <#
    .SYNOPSIS
        Returns true only when the envelope hash matches current criteria text.
    .DESCRIPTION
        Unbound envelopes (no criteriaHash) return false — a PREFIX-OK line
        alone is not a receipt against rewritten done criteria. Optional
        -ContractId, when passed, must match envelope contractId.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [object] $Envelope,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $CriteriaText,

        [string] $ContractId
    )

    $boundHash = Get-SpineObjectPropertyValue -Object $Envelope -Name 'criteriaHash'
    if ([string]::IsNullOrWhiteSpace([string]$boundHash)) {
        return $false
    }

    $expected = Get-SpineCriteriaHash -Text $CriteriaText
    if ($boundHash -cne $expected) {
        return $false
    }

    if (-not [string]::IsNullOrWhiteSpace($ContractId)) {
        $gotId = Get-SpineObjectPropertyValue -Object $Envelope -Name 'contractId'
        if ([string]$gotId -cne $ContractId) {
            return $false
        }
    }

    return $true
}

function ConvertFrom-SpineMixedJsonOutput {
    <#
    .SYNOPSIS
        Parses the first JSON object or array from mixed stdout (warnings + JSON + summary).
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [string[]] $Lines
    )

    process {
        $text = ($Lines -join "`n").Trim()
        if ([string]::IsNullOrWhiteSpace($text)) {
            throw 'No JSON object found in output lines.'
        }

        # Pure JSON succeeds; mixed stdout (JSON + trailing summary / noise) recovers in catch.
        try {
            return ($text | ConvertFrom-Json)
        }
        catch {
            if ($text -match '(?s)(\{.*\}|\[.*\])') {
                return ($Matches[1] | ConvertFrom-Json)
            }

            throw 'No JSON object found in output lines.'
        }
    }
}

function Write-SpineBaselineJson {
    <#
    .SYNOPSIS
        Writes an object as UTF-8 JSON (no BOM) to LiteralPath.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $LiteralPath,

        [Parameter(Mandatory)]
        [object] $Object,

        [int] $Depth = 8
    )

    $json = $Object | ConvertTo-Json -Depth $Depth
    Set-SpineContentUtf8 -LiteralPath $LiteralPath -Value $json
}
