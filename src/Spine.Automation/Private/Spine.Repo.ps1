function Find-SpineRepoRoot {
    <#
    .SYNOPSIS
        Walks parent directories until a marker file exists.
    .PARAMETER StartDir
        Directory to begin the walk (defaults to current location).
    .PARAMETER MarkerRelativePath
        Repo marker relative path (default: docs/framework-manifest.yml).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $StartDir = (Get-Location).Path,

        [string] $MarkerRelativePath = 'docs/framework-manifest.yml'
    )

    if ([string]::IsNullOrWhiteSpace($StartDir)) {
        return $null
    }

    $d = $StartDir
    while ($true) {
        $marker = Join-SpinePath $d $MarkerRelativePath
        if ($marker -and (Test-Path -LiteralPath $marker)) {
            return $d
        }

        $parent = Split-Path -Path $d -Parent
        if ([string]::IsNullOrEmpty($parent) -or ($parent -eq $d)) {
            return $null
        }

        $d = $parent
    }
}

function ConvertTo-SpineRelativePath {
    <#
    .SYNOPSIS
        Returns a forward-slash relative path from BasePath to TargetPath.
    .DESCRIPTION
        Uses [System.IO.Path]::GetRelativePath when available; falls back for PS 5.1 / .NET Framework.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $BasePath,

        [Parameter(Mandatory)]
        [string] $TargetPath
    )

    $base = (Resolve-Path -LiteralPath $BasePath).Path
    $target = (Resolve-Path -LiteralPath $TargetPath).Path

    $relative = $null
    try {
        $relative = [System.IO.Path]::GetRelativePath($base, $target)
    }
    catch {
        if ($target.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)) {
            $relative = $target.Substring($base.Length).TrimStart('\', '/')
        }
        else {
            $relative = $target
        }
    }

    return $relative.Replace('\', '/')
}
