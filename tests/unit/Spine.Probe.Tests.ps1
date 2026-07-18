BeforeAll {
    $repoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $moduleRoot = Join-Path $repoRoot 'src/Spine.Automation'
    Import-Module (Join-Path $moduleRoot 'Spine.Automation.psd1') -Force
}

Describe 'Spine.Probe' {
    It 'Write-SpineProbeResult emits JSON by default' {
        $out = Write-SpineProbeResult -Payload @{ ok = $true }
        ($out | Out-String).Trim() | Should -Match '"ok"\s*:\s*true'
    }

    It 'Write-SpineProbeResult emits summary line with AgentSummary' {
        Write-SpineProbeResult -Payload @{} -AgentSummary -SummaryLine 'PROBE-OK exit=0' |
            Should -Be 'PROBE-OK exit=0'
    }

    It 'Write-SpineProbeEnvelope emits standard probe envelope JSON' {
        $raw = Write-SpineProbeEnvelope -Data @{ hosts = @() } -ExitCode 0 -SafetyTier 1 -Summary 'ok'
        $obj = $raw | ConvertFrom-Json
        Assert-SpineProbeEnvelope -Envelope $obj
        $obj.PSObject.Properties.Name | Should -Contain 'data'
        $obj.ok | Should -BeTrue
        $obj.exitCode | Should -Be 0
        $obj.safetyTier | Should -Be 1
        $obj.summary | Should -Be 'ok'
    }

    It 'Write-SpineProbeEnvelope AgentSummary defaults to PROBE-FAIL' {
        Write-SpineProbeEnvelope -Data @{} -ExitCode 2 -AgentSummary |
            Should -Be 'PROBE-FAIL exit=2'
    }

    It 'Assert-SpineProbeEnvelope rejects ok/exitCode mismatch' {
        $bad = [pscustomobject]@{
            ok = $true
            exitCode = 1
            safetyTier = 1
            summary = ''
            data = @{}
        }
        { Assert-SpineProbeEnvelope -Envelope $bad } | Should -Throw '*inconsistent*'
    }

    It 'ConvertFrom-SpineMixedJsonOutput parses leading JSON' {
        $obj = ConvertFrom-SpineMixedJsonOutput -Lines '{ "a": 1 }'
        $obj.a | Should -Be 1
    }

    It 'ConvertFrom-SpineMixedJsonOutput parses JSON embedded in noise' {
        $obj = ConvertFrom-SpineMixedJsonOutput -Lines @('warn line', '{ "b": 2 }', 'PROBE-OK')
        $obj.b | Should -Be 2
    }

    It 'Write-SpineBaselineJson writes JSON file' {
        $path = Join-Path $TestDrive 'baseline.json'
        Write-SpineBaselineJson -LiteralPath $path -Object @{ version = '0.1.1' }
        $text = [System.IO.File]::ReadAllText($path)
        $text | Should -Match '"version"\s*:\s*"0\.1\.1"'
    }
}
