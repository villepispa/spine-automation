#requires -Version 7.2
<#
.SYNOPSIS
  Tiny tiered sample for product ShellGuard smoke.

.DESCRIPTION
  **Safety tier: 1** (read-only hello; no writes).

  Used by Test-ProductShellGuard.ps1 as a catalog allow case.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Write-Output 'PRODUCT-SHELLGUARD-HELLO'
