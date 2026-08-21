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

    It 'Write-SpineProbeResult -Json alone emits JSON only' {
        $out = @(Write-SpineProbeResult -Payload @{ ok = $true } -Json)
        $out.Count | Should -Be 1
        ($out | Out-String).Trim() | Should -Match '"ok"\s*:\s*true'
    }

    It 'Write-SpineProbeResult -Json -AgentSummary emits JSON then summary' {
        $out = @(Write-SpineProbeResult -Payload @{ ok = $true } -Json -AgentSummary -SummaryLine 'PROBE-OK exit=0')
        $out.Count | Should -BeGreaterThan 1
        ($out | Out-String) | Should -Match '"ok"'
        $out[-1] | Should -Be 'PROBE-OK exit=0'
        $obj = ConvertFrom-SpineMixedJsonOutput -Lines ($out | ForEach-Object { "$_" })
        $obj.ok | Should -BeTrue
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

    It 'Write-SpineProbeEnvelope -Json -AgentSummary mixed stdout is parseable' {
        $out = @(Write-SpineProbeEnvelope -Data @{ x = 1 } -ExitCode 0 -Json -AgentSummary)
        $out[-1] | Should -Be 'PROBE-OK exit=0'
        $obj = ConvertFrom-SpineMixedJsonOutput -Lines ($out | ForEach-Object { "$_" })
        Assert-SpineProbeEnvelope -Envelope $obj
        $obj.data.x | Should -Be 1
        $obj.ok | Should -BeTrue
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

    It 'ConvertFrom-SpineMixedJsonOutput parses leading JSON with trailing summary' {
        $obj = ConvertFrom-SpineMixedJsonOutput -Lines @('{ "c": 3 }', 'PROBE-OK exit=0')
        $obj.c | Should -Be 3
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

    It 'New-SpineProbeEnvelope omits criteriaHash and contractId when unset' {
        $env = New-SpineProbeEnvelope -Data @{} -ExitCode 0
        $env.PSObject.Properties.Name | Should -Not -Contain 'criteriaHash'
        $env.PSObject.Properties.Name | Should -Not -Contain 'contractId'
        Assert-SpineProbeEnvelope -Envelope $env
    }

    It 'New-SpineProbeEnvelope includes optional criteriaHash and contractId' {
        $hash = Get-SpineCriteriaHash -Text 'done when tests pass'
        $env = New-SpineProbeEnvelope -Data @{} -ExitCode 0 -CriteriaHash $hash -ContractId 'probe-contract'
        $env.criteriaHash | Should -Be $hash
        $env.contractId | Should -Be 'probe-contract'
        Assert-SpineProbeEnvelope -Envelope $env
    }

    It 'Get-SpineCriteriaHash matches SHA-256 of UTF-8 abc' {
        Get-SpineCriteriaHash -Text 'abc' |
            Should -Be 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
    }

    It 'Get-SpineCriteriaHash -LiteralPath matches -Text for the same bytes' {
        $path = Join-Path $TestDrive 'criteria.txt'
        $text = "gate findings=0`n"
        [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
        (Get-SpineCriteriaHash -LiteralPath $path) | Should -Be (Get-SpineCriteriaHash -Text $text)
    }

    It 'Assert-SpineProbeEnvelope rejects malformed criteriaHash' {
        $bad = [pscustomobject]@{
            ok           = $true
            exitCode     = 0
            safetyTier   = 1
            summary      = ''
            data         = @{}
            criteriaHash = 'not-a-sha256'
        }
        { Assert-SpineProbeEnvelope -Envelope $bad } | Should -Throw '*criteriaHash*'
    }

    It 'Test-SpineProbeCriteriaBinding is true when hash matches current criteria' {
        $text = 'AC: Pester green; no private IDs'
        $env = New-SpineProbeEnvelope -Data @{} -ExitCode 0 `
            -CriteriaHash (Get-SpineCriteriaHash -Text $text) `
            -ContractId 'oss-023'
        Test-SpineProbeCriteriaBinding -Envelope $env -CriteriaText $text -ContractId 'oss-023' |
            Should -BeTrue
    }

    It 'Test-SpineProbeCriteriaBinding is false when criteria were rewritten' {
        $old = 'AC: tests pass'
        $new = 'AC: tests pass AND docs published'
        $env = New-SpineProbeEnvelope -Data @{ summary = 'PROBE-OK' } -ExitCode 0 `
            -CriteriaHash (Get-SpineCriteriaHash -Text $old)
        Test-SpineProbeCriteriaBinding -Envelope $env -CriteriaText $new | Should -BeFalse
    }

    It 'Test-SpineProbeCriteriaBinding is false for unbound PREFIX-OK envelopes' {
        $env = New-SpineProbeEnvelope -Data @{} -ExitCode 0 -Summary 'PROBE-OK'
        Test-SpineProbeCriteriaBinding -Envelope $env -CriteriaText 'any later criteria' |
            Should -BeFalse
    }

    It 'Write-SpineProbeEnvelope JSON includes optional binding fields' {
        $hash = Get-SpineCriteriaHash -Text 'bind-me'
        $raw = Write-SpineProbeEnvelope -Data @{ n = 1 } -ExitCode 0 `
            -CriteriaHash $hash -ContractId 'c1' -Summary 'PROBE-OK'
        $obj = $raw | ConvertFrom-Json
        Assert-SpineProbeEnvelope -Envelope $obj
        $obj.criteriaHash | Should -Be $hash
        $obj.contractId | Should -Be 'c1'
    }
}
