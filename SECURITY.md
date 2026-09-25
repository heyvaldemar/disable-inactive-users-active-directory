# Security Policy

## Supported versions

| Version                                        | Status             |
|------------------------------------------------|--------------------|
| Current `main` and the latest tagged release   | :white_check_mark: |
| Older tags                                     | :x:                |

Fixes land on `main` and ship as a new tag; older tags are not patched in place.

## Reporting a vulnerability

Report privately through GitHub: **Security → Report a vulnerability** on this repository (private vulnerability reporting is enabled). Email to v@valdemar.ai also works. The process is described at [heyvaldemar.com/security](https://heyvaldemar.com/security/).

You can expect an acknowledgment within 7 days. This project does not operate a bounty program; researchers who submit valid, responsibly disclosed reports receive public credit in the release notes and the changelog.

Please do not open public GitHub issues for security reports.

## Running this script safely

The script disables and moves user accounts, which is a change that helpdesk feels immediately. It supports `-WhatIf` and always writes the CSV report first, so the intended change can be read before it happens. Run it that way, review the CSV, then run it for real.

It needs rights to disable and move user objects, and nothing else. Two accuracy notes worth knowing before you schedule it: `lastLogonTimestamp` replicates lazily (9 to 14 days by default), so a threshold under 30 days produces false positives, and a service account that authenticates in a way Active Directory does not stamp will look dormant.

GitHub Actions used by this repository are pinned by commit SHA, and CI runs on every push and weekly.
