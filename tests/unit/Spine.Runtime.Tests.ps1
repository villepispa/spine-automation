BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $moduleRoot = Join-Path $repoRoot 'src/Spine.Automation'
    Import-Module (Join-Path $moduleRoot 'Spine.Automation.psd1') -Force
}

Describe 'Spine.Runtime' {
    It 'Join-SpinePath joins multiple segments' {
        Join-SpinePath 'C:\temp' 'a' 'b.txt' | Should -Be (Join-Path 'C:\temp' (Join-Path 'a' 'b.txt'))
    }

    It 'Get-SpineObjectArray wraps scalar' {
        @(Get-SpineObjectArray -InputObject 'x').Count | Should -Be 1
    }

    It 'Write-SpineObjectArray preserves single element as array' {
        $arr = Write-SpineObjectArray -InputObject 1
        $arr.Count | Should -Be 1
        ,$arr | Should -BeOfType [object[]]
    }

    It 'Set-SpineContentUtf8 writes UTF-8 without BOM' {
        $path = Join-Path $TestDrive 'utf8.txt'
        Set-SpineContentUtf8 -LiteralPath $path -Value 'abc'
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $bytes[0..2] | Should -Not -Contain 0xEF
        [System.Text.Encoding]::UTF8.GetString($bytes) | Should -Be 'abc'
    }

    It 'Get-SpineObjectPropertyValue reads property under strict mode' {
        Set-StrictMode -Version Latest
        $obj = [pscustomobject]@{ tier = 1 }
        Get-SpineObjectPropertyValue -Object $obj -Name 'tier' | Should -Be 1
        Get-SpineObjectPropertyValue -Object $obj -Name 'missing' | Should -BeNullOrEmpty
    }

    It 'reports host version' {
        Get-SpinePowerShellVersion | Should -BeOfType [version]
        Test-SpineIsPowerShellCore | Should -Be ($PSVersionTable.PSVersion.Major -ge 6)
    }
}
