<#
.SYNOPSIS
    Disables Active Directory accounts that have not signed in for a given
    number of days, then moves them to a quarantine organizational unit.

.DESCRIPTION
    Dormant accounts are the ones attackers like: nobody notices a login on an
    account nobody uses. This script finds accounts whose last logon is older
    than -Days (and accounts that have never logged on at all), writes them to
    a CSV, disables them, stamps the date into the description, and moves them
    to -InactiveUserOU.

    It supports -WhatIf. Run it that way first and read the CSV: an account
    disabled by mistake is a support call, and a service account that
    authenticates in a way AD does not stamp will show up here as dormant.

    Accuracy note: lastLogonTimestamp replicates lazily, by default within 9 to
    14 days. Treat -Days below 30 as unreliable rather than aggressive.

.PARAMETER SearchBase
    Distinguished name of the OU to search, for example
    "OU=Users,DC=example,DC=com".

.PARAMETER InactiveUserOU
    Distinguished name of the OU that disabled accounts are moved to.

.PARAMETER Days
    An account is dormant when its last logon is older than this. Default 90.

.PARAMETER LogFolder
    Folder for the CSV report. Created if missing. Default C:\Scripts\Disable-Inactive-Users\Log.

.EXAMPLE
    .\disable-inactive-users-active-directory.ps1 -SearchBase "OU=Users,DC=example,DC=com" -InactiveUserOU "OU=Disabled,OU=Users,DC=example,DC=com" -WhatIf

    Writes the CSV and shows which accounts would be disabled and moved.

.NOTES
    Needs the ActiveDirectory module (RSAT AD DS tools) and rights to disable
    and move user objects. Excludes accounts protected by AdminSDHolder is not
    automatic: review the CSV.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [string] $SearchBase,

    [Parameter(Mandatory = $true)]
    [string] $InactiveUserOU,

    [ValidateRange(1, 3650)]
    [int] $Days = 90,

    [string] $LogFolder = 'C:\Scripts\Disable-Inactive-Users\Log'
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$cutoff = (Get-Date).AddDays(-$Days)
$cutoffFileTime = $cutoff.ToFileTime()

# The report is written in every mode, -WhatIf included: a dry run is the run
# that most needs it. Without -WhatIf:$false here both New-Item and
# Export-Csv inherit the preference, write nothing, and the line below still
# says the report was written.
if (-not (Test-Path -LiteralPath $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force -WhatIf:$false | Out-Null
}
$logFile = Join-Path $LogFolder ("Disable-Inactive-Users_{0:yyyy-MM-dd_HH-mm-ss}.csv" -f (Get-Date))

# A string filter, not a script block: the script-block form silently stops
# expanding variables in some PowerShell versions and then matches nothing,
# which reads as "no dormant accounts" instead of as an error.
$filter = "(lastLogonTimestamp -lt $cutoffFileTime -or -not (lastLogonTimestamp -like '*')) -and whenCreated -lt '$($cutoff.ToString('yyyy-MM-dd HH:mm:ss'))' -and enabled -eq 'True'"

$users = @(Get-ADUser -Filter $filter -SearchBase $SearchBase -Properties DisplayName, DistinguishedName, whenCreated, lastLogonTimestamp, Description)

$report = $users | Select-Object DisplayName, DistinguishedName, whenCreated, Description,
    @{ n = 'lastLogonDate'; e = { if ($_.lastLogonTimestamp) { [datetime]::FromFileTime($_.lastLogonTimestamp) } else { 'never' } } }

$report | Export-Csv -LiteralPath $logFile -NoTypeInformation -Encoding UTF8 -WhatIf:$false
Write-Output "$($users.Count) dormant account(s) written to $logFile"

if ($users.Count -eq 0) { return }

$stamp = "Account disabled on {0:yyyy-MM-dd} by disable-inactive-users-active-directory" -f (Get-Date)
$disabled = 0

foreach ($user in $users) {
    if ($PSCmdlet.ShouldProcess($user.DistinguishedName, "Disable, describe, and move to $InactiveUserOU")) {
        try {
            # Disable-ADAccount, not dsmod: dsmod is a Windows Server 2003 tool
            # that is not installed on current servers, and it fails silently
            # in a loop like this one.
            Disable-ADAccount -Identity $user.DistinguishedName
            Set-ADUser -Identity $user.DistinguishedName -Description $stamp
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $InactiveUserOU
            $disabled++
        }
        catch {
            Write-Warning "Could not process $($user.DistinguishedName): $($_.Exception.Message)"
        }
    }
}

Write-Output "$disabled account(s) disabled and moved to $InactiveUserOU"
