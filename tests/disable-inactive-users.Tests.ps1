# What the script promises, run against a stand-in for Active Directory that
# records every change it would make: dormant enabled accounts are found by a
# filter that says so, each is disabled, stamped and moved in that order,
# -WhatIf changes nothing, and one account that cannot be changed does not
# stop the rest. tests/plant-violations.py breaks each promise in a copy of
# the script and requires this file to notice.
#
#   Invoke-Pester -Path tests -Output Detailed

BeforeAll {
    $script:Script = Join-Path $PSScriptRoot '..' 'disable-inactive-users-active-directory.ps1'
    $env:PSModulePath = (Join-Path $PSScriptRoot 'stub') + [System.IO.Path]::PathSeparator + $env:PSModulePath
    $script:Base = 'OU=Users,DC=example,DC=test'
    $script:Target = 'OU=Disabled,OU=Users,DC=example,DC=test'

    function New-User([string] $Name, $LastLogon) {
        [pscustomobject]@{
            DisplayName = $Name
            DistinguishedName = "CN=$Name,$Base"
            whenCreated = (Get-Date).AddYears(-2)
            Description = ''
            lastLogonTimestamp = $(if ($LastLogon) { $LastLogon.ToFileTime() } else { $null })
        }
    }
    function Calls([string] $Verb) { @($global:AdStub.Calls | Where-Object Verb -eq $Verb) }
}

Describe 'disable-inactive-users-active-directory.ps1' {
    BeforeEach {
        $script:Log = Join-Path ([System.IO.Path]::GetTempPath()) ("ad-log-" + [guid]::NewGuid())
        $global:AdStub = @{
            Calls  = [System.Collections.Generic.List[object]]::new()
            FailOn = @()
            Users  = @(
                (New-User 'Ann' (Get-Date).AddDays(-200)),
                (New-User 'Bob' $null)
            )
        }
    }
    AfterEach { Remove-Item -LiteralPath $Log -Recurse -Force -ErrorAction SilentlyContinue }

    It 'asks only for enabled accounts idle longer than -Days, below the search base' {
        & $Script -SearchBase $Base -InactiveUserOU $Target -Days 90 -LogFolder $Log -WhatIf | Out-Null
        $get = Calls 'Get'
        $get.Count | Should -Be 1
        $get[0].SearchBase | Should -Be $Base
        $get[0].Filter | Should -Match "enabled -eq 'True'"
        $get[0].Filter | Should -Match 'lastLogonTimestamp -lt (\d+)'
        $cut = [datetime]::FromFileTime([long]($get[0].Filter -replace '.*lastLogonTimestamp -lt (\d+).*', '$1'))
        ((Get-Date).AddDays(-90) - $cut).Duration().TotalMinutes | Should -BeLessThan 5
    }

    It 'changes nothing under -WhatIf, and still writes the report' {
        & $Script -SearchBase $Base -InactiveUserOU $Target -LogFolder $Log -WhatIf | Out-Null
        (Calls 'Disable').Count + (Calls 'Describe').Count + (Calls 'Move').Count | Should -Be 0
        $csv = Get-ChildItem -LiteralPath $Log -Filter '*.csv' | Select-Object -First 1
        $csv | Should -Not -BeNullOrEmpty
        @(Import-Csv -LiteralPath $csv.FullName).DisplayName | Should -Be @('Ann', 'Bob')
    }

    It 'disables, stamps and moves every dormant account, in that order' {
        $out = & $Script -SearchBase $Base -InactiveUserOU $Target -LogFolder $Log -Confirm:$false
        foreach ($u in $global:AdStub.Users) {
            $mine = @($global:AdStub.Calls | Where-Object { $_.Identity -eq $u.DistinguishedName })
            ($mine.Verb -join ',') | Should -Be 'Disable,Describe,Move'
            $mine[1].Description | Should -Match '^Account disabled on \d{4}-\d{2}-\d{2}'
            $mine[2].TargetPath | Should -Be $Target
        }
        $out | Should -Contain "2 account(s) disabled and moved to $Target"
    }

    It 'goes on past an account it cannot change, and does not count it' {
        $global:AdStub.FailOn = @("CN=Ann,$Base")
        $out = & $Script -SearchBase $Base -InactiveUserOU $Target -LogFolder $Log -Confirm:$false -WarningVariable w -WarningAction SilentlyContinue
        ($w -join ' ') | Should -Match 'Could not process CN=Ann'
        (Calls 'Move').Identity | Should -Be @("CN=Bob,$Base")
        $out | Should -Contain "1 account(s) disabled and moved to $Target"
    }

    It 'does nothing when nothing is dormant' {
        $global:AdStub.Users = @()
        $out = & $Script -SearchBase $Base -InactiveUserOU $Target -LogFolder $Log -Confirm:$false
        (Calls 'Disable').Count | Should -Be 0
        $out | Should -Match '^0 dormant account'
    }

    It 'refuses -Days 0, which would take every account' {
        { & $Script -SearchBase $Base -InactiveUserOU $Target -Days 0 -LogFolder $Log -Confirm:$false } | Should -Throw
        (Calls 'Disable').Count | Should -Be 0
    }
}
