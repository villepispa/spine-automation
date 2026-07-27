#requires -Version 7.2
<#
.SYNOPSIS
  Untiered sample — should HOLD under product ShellGuard.

.DESCRIPTION
  Intentionally omits **Safety tier:** so the gate treats this as external Tier 3.
#>
[CmdletBinding()]
param()

Write-Output 'should-hold'
