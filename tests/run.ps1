# Runs the Pester suite under tests/, installing Pester 5 first when the
# machine does not have it, and exits with the number of failed tests.
# CI and tests/plant-violations.py both call this, so the two cannot drift.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if (-not (Get-Module -ListAvailable Pester | Where-Object Version -ge '5.5.0')) {
    Install-PSResource -Name Pester -Version '[5.5,6.0)' -TrustRepository -Scope CurrentUser -Quiet
}
Import-Module Pester -MinimumVersion 5.5
$c = New-PesterConfiguration
$c.Run.Path = $PSScriptRoot
$c.Run.PassThru = $true
$c.Output.Verbosity = 'Detailed'
$r = Invoke-Pester -Configuration $c
exit $r.FailedCount
