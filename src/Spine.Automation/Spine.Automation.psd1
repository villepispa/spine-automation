@{
    RootModule        = 'Spine.Automation.psm1'
    ModuleVersion     = '0.1.1'
    GUID              = 'a4c8e2f1-9b3d-4e7a-8c1f-2d6e9a0b5c3f'
    Author            = 'Ville Pispa'
    CompanyName       = 'Spine'
    Copyright         = '(c) 2026 Ville Pispa. MIT License.'
    Description       = 'Shared PowerShell primitives for dual-host catalog and product modules.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
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
    PrivateData       = @{
        PSData = @{
            Tags       = @('Spine', 'Automation', 'PowerShell')
            LicenseUri = 'https://opensource.org/licenses/MIT'
        }
    }
}
