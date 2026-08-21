#requires -Version 7.2
<#
.SYNOPSIS
  Untiered tests/Invoke-*Pester.ps1 fixture (must HOLD).

.DESCRIPTION
  Catalog-shaped filename without **Safety tier:** — product ShellGuard HOLD.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Write-Output 'PRODUCT-SHELLGUARD-UNTIERED-PESTER'
