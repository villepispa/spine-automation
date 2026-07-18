BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $moduleRoot = Join-Path $repoRoot 'src/Spine.Automation'
    Import-Module (Join-Path $moduleRoot 'Spine.Automation.psd1') -Force
    $script:FixtureRoot = Join-Path (Split-Path -Path $PSScriptRoot -Parent) 'fixtures/mini-repo'
}

Describe 'Spine.Repo' {
    It 'Find-SpineRepoRoot walks up from nested dir' {
        $start = Join-Path $script:FixtureRoot 'nested'
        Find-SpineRepoRoot -StartDir $start | Should -Be $script:FixtureRoot
    }

    It 'Find-SpineRepoRoot returns null when marker missing' {
        Find-SpineRepoRoot -StartDir $TestDrive | Should -BeNullOrEmpty
    }

    It 'ConvertTo-SpineRelativePath normalizes slashes' {
        $base = $script:FixtureRoot
        $target = Join-Path $script:FixtureRoot 'nested/child.txt'
        $rel = ConvertTo-SpineRelativePath -BasePath $base -TargetPath $target
        $rel | Should -Match '^nested/child\.txt$'
    }
}
