#requires -Version 7.2
<#
.SYNOPSIS
  Non-runner under tests/unit (must stay external).

.DESCRIPTION
  **Safety tier: 1** (read-only fixture).

  Path is not tests/Invoke-*Pester.ps1 — product ShellGuard HOLD.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Write-Output 'PRODUCT-SHELLGUARD-UNIT-NOT-RUNNER'
