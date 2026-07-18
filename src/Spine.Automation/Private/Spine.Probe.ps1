function Write-SpineProbeResult {
    <#
    .SYNOPSIS
        Writes probe stdout as JSON or a single AgentSummary line.
    .PARAMETER Payload
        Object serialized when -AgentSummary is not set.
    .PARAMETER SummaryLine
        One-line summary when -AgentSummary is set (caller builds tag/exit detail).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object] $Payload,

        [switch] $AgentSummary,

        [string] $SummaryLine,

        [int] $Depth = 10
    )

    if ($AgentSummary) {
        if (-not [string]::IsNullOrWhiteSpace($SummaryLine)) {
            Write-Output $SummaryLine
        }
        return
    }

    $Payload | ConvertTo-Json -Depth $Depth
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

        [string] $Summary = ''
    )

    return [pscustomobject]@{
        ok         = ($ExitCode -eq 0)
        exitCode   = $ExitCode
        safetyTier = $SafetyTier
        summary    = $Summary
        data       = $Data
    }
}

function Write-SpineProbeEnvelope {
    <#
    .SYNOPSIS
        Writes a standard probe envelope as JSON or an AgentSummary line.
    .DESCRIPTION
        Builds { ok, exitCode, safetyTier, summary, data } and routes through
        Write-SpineProbeResult. When -AgentSummary is set without -SummaryLine,
        emits PROBE-OK / PROBE-FAIL exit=N from ExitCode.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $Data,

        [int] $ExitCode = 0,

        [int] $SafetyTier = 1,

        [string] $Summary = '',

        [switch] $AgentSummary,

        [string] $SummaryLine,

        [int] $Depth = 10
    )

    $envelope = New-SpineProbeEnvelope -Data $Data -ExitCode $ExitCode -SafetyTier $SafetyTier -Summary $Summary

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

    Write-SpineProbeResult -Payload $envelope -AgentSummary:$AgentSummary -SummaryLine $line -Depth $Depth
}

function Assert-SpineProbeEnvelope {
    <#
    .SYNOPSIS
        Validates a standard probe envelope (required keys + ok/exitCode consistency).
    .DESCRIPTION
        Throws on failure — intended for Pester and catalog smoke checks.
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

        if ($text.StartsWith('{') -or $text.StartsWith('[')) {
            return ($text | ConvertFrom-Json)
        }

        if ($text -match '(?s)(\{.*\}|\[.*\])') {
            return ($Matches[1] | ConvertFrom-Json)
        }

        throw 'No JSON object found in output lines.'
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
