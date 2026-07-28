@{
    # Slim portable settings for product / satellite repos.
    Severity = @('Error', 'Warning')

    ExcludeRules = @(
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseBOMForUnicodeEncodedFile'
    )
}
