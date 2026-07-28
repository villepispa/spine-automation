#requires -Version 7.2
<#
.SYNOPSIS
  Pester coverage for templates/ps-workspace sample script Get-PsWorkspaceHello.ps1.
#>

Describe 'Get-PsWorkspaceHello' {
    BeforeAll {
        $script:HelloScript = Join-Path $PSScriptRoot '..' 'scripts' 'Get-PsWorkspaceHello.ps1'
    }

    It 'emits JSON with ok=true and greeting' {
        $raw = & pwsh -NoProfile -File $script:HelloScript -Name 'Pester'
        $obj = $raw | ConvertFrom-Json
        $obj.ok | Should -BeTrue
        $obj.name | Should -Be 'Pester'
        $obj.greeting | Should -Match 'Pester'
    }

    It 'exits 0' {
        & pwsh -NoProfile -File $script:HelloScript | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
}
