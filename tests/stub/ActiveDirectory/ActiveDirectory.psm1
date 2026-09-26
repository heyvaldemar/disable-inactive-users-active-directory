# A stand-in for the ActiveDirectory module, for tests only. It records every
# call the script makes and returns the accounts a test puts in
# $global:AdStub.Users, so the script's logic runs anywhere PowerShell does
# and every change it would make to a directory can be asserted.
function Get-ADUser {
    param([string] $Filter, [string] $SearchBase, [string[]] $Properties)
    $global:AdStub.Calls.Add([pscustomobject]@{ Verb = 'Get'; Filter = $Filter; SearchBase = $SearchBase })
    $global:AdStub.Users
}
function Disable-ADAccount {
    param([string] $Identity)
    if ($global:AdStub.FailOn -contains $Identity) { throw "access denied on $Identity" }
    $global:AdStub.Calls.Add([pscustomobject]@{ Verb = 'Disable'; Identity = $Identity })
}
function Set-ADUser {
    param([string] $Identity, [string] $Description)
    $global:AdStub.Calls.Add([pscustomobject]@{ Verb = 'Describe'; Identity = $Identity; Description = $Description })
}
function Move-ADObject {
    param([string] $Identity, [string] $TargetPath)
    $global:AdStub.Calls.Add([pscustomobject]@{ Verb = 'Move'; Identity = $Identity; TargetPath = $TargetPath })
}
Export-ModuleMember -Function Get-ADUser, Disable-ADAccount, Set-ADUser, Move-ADObject
