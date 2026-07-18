BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $moduleRoot = Join-Path $repoRoot 'src/Spine.Automation'
    Import-Module (Join-Path $moduleRoot 'Spine.Automation.psd1') -Force
}

Describe 'Spine.Process' {
    It 'ConvertTo-SpineWindowsArgumentString quotes spaces' {
        ConvertTo-SpineWindowsArgumentString -Value 'hello world' | Should -Be '"hello world"'
    }

    It 'ConvertTo-SpineWindowsArgumentString escapes embedded quotes' {
        ConvertTo-SpineWindowsArgumentString -Value 'say "hi"' | Should -Be '"say \"hi\""'
    }

    It 'ConvertTo-SpineWindowsArgumentString passes plain tokens' {
        ConvertTo-SpineWindowsArgumentString -Value 'plain' | Should -Be 'plain'
    }

    It 'Test-SpineElevation returns bool' {
        { Test-SpineElevation } | Should -Not -Throw
        $elevated = Test-SpineElevation
        ($elevated -is [bool]) | Should -Be $true
    }
}
