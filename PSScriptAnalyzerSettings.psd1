@{
    # Product lint settings for Spine.Automation (scripts/ + src/Spine.Automation/).
    Severity = @('Error', 'Warning')

    # Workspace files are UTF-8 without BOM; helpers are not ShouldProcess cmdlets.
    ExcludeRules = @(
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseBOMForUnicodeEncodedFile'
    )
}
