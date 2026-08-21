#requires -Version 7.2
<#
.SYNOPSIS
  Dummy product Pester runner for ShellGuard catalog smoke.

.DESCRIPTION
  **Safety tier: 1** (read-only fixture; does not invoke Pester).

  Used by Test-ProductShellGuard.ps1 as a tests/Invoke-*Pester.ps1 allow case.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Write-Output 'PRODUCT-SHELLGUARD-PESTER-RUNNER'
