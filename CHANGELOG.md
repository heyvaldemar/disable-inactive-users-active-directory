# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_(no unreleased changes yet)_

## [1.1.0] - 2026-09-26

### Added

- **Tests of what the script does, and proof that they can fail.** A Pester suite runs the script for real and asserts its behaviour; `tests/plant-violations.py` breaks it 7 ways on a copy and requires the suite to notice each. Both run in CI on every push.

### Fixed

- **A dry run writes the report it says it wrote.** Under `-WhatIf` the script printed "N dormant account(s) written to <file>" and wrote nothing: `New-Item` and `Export-Csv` inherited the dry-run preference along with the account changes. The report is now written in every mode, and the account changes still honour `-WhatIf`. Found by the new test on the first run.

## [1.0.0] - 2026-09-03

### Fixed

- **Accounts were disabled with `dsmod`,** a Windows Server 2003 tool that is
  not present on current servers and fails quietly inside a loop: the account
  was then moved to the disabled OU while still enabled. `Disable-ADAccount`
  from the same ActiveDirectory module already in use does the job and reports
  failure.
- **The search filter was a script block.** In that form the comparison values
  are not always expanded, and the query silently matches nothing, which reads
  as "no dormant accounts" rather than as an error. The filter is now a string.
- Already-disabled accounts are excluded, so a rerun no longer rewrites the
  description of accounts it disabled on an earlier pass.

### Added

- **`-WhatIf` support**, and the CSV report is always written before any change,
  so the intended change can be reviewed before it is made.
- **Parameters instead of edit-the-file variables**: `-SearchBase`,
  `-InactiveUserOU`, `-Days` and `-LogFolder`. The two organizational units are
  mandatory, so the script cannot run against the wrong directory by inheriting
  someone else's defaults.
- **Comment-based help** with the replication caveat stated up front:
  `lastLogonTimestamp` replicates lazily, so a threshold under 30 days produces
  false positives.
- CI that parses the script and runs PSScriptAnalyzer at Error and Warning
  severity on every push and weekly.

[Unreleased]: https://github.com/heyvaldemar/disable-inactive-users-active-directory/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/heyvaldemar/disable-inactive-users-active-directory/releases/tag/v1.0.0
