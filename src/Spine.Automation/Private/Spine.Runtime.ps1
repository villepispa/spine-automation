function Get-SpinePowerShellVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param()

    return [version]$PSVersionTable.PSVersion.ToString()
}

function Test-SpineIsPowerShellCore {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    return ($PSVersionTable.PSVersion.Major -ge 6)
}

function Test-SpineIsWindowsPowerShell51 {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    return (-not (Test-SpineIsPowerShellCore) -and $PSVersionTable.PSVersion.Major -eq 5)
}

function Join-SpinePath {
    <#
    .SYNOPSIS
        Joins path segments; safe on Windows PowerShell 5.1 (single Join-Path child limit).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments = $true)]
        [string[]] $Segment
    )

    if (-not $Segment -or $Segment.Count -eq 0) {
        return $null
    }

    $result = $Segment[0]
    for ($i = 1; $i -lt $Segment.Count; $i++) {
        if ([string]::IsNullOrWhiteSpace($Segment[$i])) { continue }
        $result = Join-Path -Path $result -ChildPath $Segment[$i]
    }

    return $result
}

function Write-SpineObjectArray {
    <#
    .SYNOPSIS
        Returns a value as an array even when it has a single element (PS 5.1 unwrap safe).
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        $InputObject
    )

    $arr = @($InputObject)
    if ($arr.Count -le 1) {
        return ,$arr
    }

    return $arr
}

function Get-SpineObjectArray {
    <#
    .SYNOPSIS
        Normalizes a value that may have been unwrapped from a single-element array (PS 5.1).
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowNull()]
        $InputObject
    )

    if ($null -eq $InputObject) {
        return @()
    }

    return @($InputObject)
}

function Get-SpineObjectPropertyValue {
    <#
    .SYNOPSIS
        Reads a note property safely under Set-StrictMode.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object] $Object,

        [Parameter(Mandatory)]
        [string] $Name
    )

    if ($null -eq $Object) { return $null }

    $prop = $Object.PSObject.Properties[$Name]
    if ($null -eq $prop) { return $null }

    return $prop.Value
}

function Set-SpineContentUtf8 {
    <#
    .SYNOPSIS
        Writes text as UTF-8 (no BOM) on PS 5.1 and PS 7+.
    .DESCRIPTION
        Writes the string exactly as provided; does not append a trailing newline.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $LiteralPath,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $Value
    )

    process {
        $text = if ($null -eq $Value) { '' } else { [string]$Value }
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        [System.IO.File]::WriteAllText($LiteralPath, $text, $utf8NoBom)
    }
}
