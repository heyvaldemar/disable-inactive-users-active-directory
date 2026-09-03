# Disable inactive Active Directory accounts

[![Script Verification](https://github.com/heyvaldemar/disable-inactive-users-active-directory/actions/workflows/verification.yml/badge.svg?branch=main)](https://github.com/heyvaldemar/disable-inactive-users-active-directory/actions/workflows/verification.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Dormant accounts are the ones attackers like: nobody notices a login on an account nobody uses. This PowerShell script finds accounts that have not signed in for a given number of days, writes them to a CSV, disables them, stamps the date into the description, and moves them to a quarantine organizational unit.

## Getting started

```powershell
# 1. Clone
git clone https://github.com/heyvaldemar/disable-inactive-users-active-directory
cd disable-inactive-users-active-directory

# 2. See what would happen, and read the CSV it writes
.\disable-inactive-users-active-directory.ps1 `
  -SearchBase "OU=Users,DC=example,DC=com" `
  -InactiveUserOU "OU=Disabled,OU=Users,DC=example,DC=com" `
  -WhatIf

# 3. Run it for real once the CSV looks right
.\disable-inactive-users-active-directory.ps1 `
  -SearchBase "OU=Users,DC=example,DC=com" `
  -InactiveUserOU "OU=Disabled,OU=Users,DC=example,DC=com" `
  -Days 90 -Confirm:$false
```

Needs the ActiveDirectory module (RSAT AD DS tools) and rights to disable and move user objects.

### What success looks like

```text
17 dormant account(s) written to C:\Scripts\Disable-Inactive-Users\Log\Disable-Inactive-Users_2026-09-03_03-15-42.csv
17 account(s) disabled and moved to OU=Disabled,OU=Users,DC=example,DC=com
```

The CSV carries the display name, the distinguished name, the creation date, the last logon date (or `never`), and the previous description, so the change can be reviewed or reversed.

## Parameters

| Parameter          | Default | What it does |
|--------------------|---------|--------------|
| `-SearchBase`      | required | Organizational unit to search. |
| `-InactiveUserOU`  | required | Where disabled accounts are moved. |
| `-Days`            | `90` | An account is dormant when its last logon is older than this. |
| `-LogFolder`       | `C:\Scripts\Disable-Inactive-Users\Log` | Where the CSV report is written. |

Both organizational units are mandatory on purpose. A script that disables accounts should never inherit someone else's default and run against the wrong directory.

## Two things to know before you schedule it

**`lastLogonTimestamp` replicates lazily.** Active Directory updates it at most once every 9 to 14 days by default, so a threshold under 30 days will flag people who logged in last week. Ninety days is the safe floor for an unattended job.

**Some service accounts never stamp a logon** in a way the directory records. They look dormant here and are not. Read the CSV on the first run and exclude what should stay enabled.

## Production checklist

- [ ] **Run with `-WhatIf` first** and read the CSV. This is the whole review.
- [ ] **Create the quarantine OU before the first run** and check that no group policy or license assignment is scoped to it in a way that surprises you.
- [ ] **Keep the CSVs.** They are the record of who was disabled and when, and the thing you reach for when someone comes back from a year of leave.
- [ ] **Exclude accounts protected by AdminSDHolder** and break-glass administrators from the search base.

## Testing

The [Script Verification](https://github.com/heyvaldemar/disable-inactive-users-active-directory/actions/workflows/verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and weekly: it parses the script, runs PSScriptAnalyzer at Error and Warning severity, checks that the comment-based help is present, and lints the workflow itself.

---

## About the maintainer

<div align="center">

**Maintained by [Vladimir Mikhalev](https://github.com/heyvaldemar)** · Docker Captain · IBM Champion · AWS Community Builder

[YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1) · [Blog](https://heyvaldemar.com) · [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)

</div>
