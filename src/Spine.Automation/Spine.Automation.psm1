#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

$PrivateRoot = Join-Path $PSScriptRoot 'Private'
. (Join-Path $PrivateRoot 'Spine.Runtime.ps1')
. (Join-Path $PrivateRoot 'Spine.Repo.ps1')
. (Join-Path $PrivateRoot 'Spine.Process.ps1')
. (Join-Path $PrivateRoot 'Spine.Probe.ps1')

Export-ModuleMember -Function @(
    'Get-SpinePowerShellVersion'
    'Test-SpineIsPowerShellCore'
    'Test-SpineIsWindowsPowerShell51'
    'Join-SpinePath'
    'Write-SpineObjectArray'
    'Get-SpineObjectArray'
    'Get-SpineObjectPropertyValue'
    'Set-SpineContentUtf8'
    'Find-SpineRepoRoot'
    'ConvertTo-SpineRelativePath'
    'Test-SpineElevation'
    'ConvertTo-SpineWindowsArgumentString'
    'Write-SpineProbeResult'
    'New-SpineProbeEnvelope'
    'Write-SpineProbeEnvelope'
    'Assert-SpineProbeEnvelope'
    'ConvertFrom-SpineMixedJsonOutput'
    'Write-SpineBaselineJson'
)
