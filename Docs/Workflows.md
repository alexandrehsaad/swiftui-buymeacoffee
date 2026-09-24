# Workflows

Run workflow logic locally using the Swift scripts in `Scripts/`.

## Overview

Workflows define triggers, permissions, runners, checkout, and publishing. Swift scripts handle validation rules,
unit and snapshot test execution, and report and documentation generation. Simple build commands and the formatting
plugin remain directly in the workflows.

Run scripts from the repository root with Swift installed. Scripts accept command-line arguments rather than requiring
GitHub Actions environment variables. They return a nonzero exit status when validation or a subprocess fails.

Tests and coverage collection require Xcode 26.5 and an iPhone 17 simulator running iOS 26.5. Use the same Xcode
installation as CI when comparing snapshots. Each runner generates its iOS application host before invoking Xcode.

## Documentation

### BuildDocumentation.swift

Build the combined DocC website:

```shell
swift Scripts/BuildDocumentation.swift
```

This generates the site in `.build/github-pages/` inside the repository and adds its landing-page redirect after a
successful build. GitHub Pages setup, artifact upload, and deployment remain in the documentation workflow.

## Tests

### RunUnitTests.swift

Run the unit tests and collect coverage data:

```shell
swift Scripts/RunUnitTests.swift
```

The runner generates the iOS test host, executes `xcodebuild test` with coverage enabled, and invokes
`CollectCodeCoverage.swift`. It saves coverage data in `.build/coverage/UnitTests/` and test results in
`.build/snapshots/UnitTests.xcresult`. Test output goes to standard error. Test or coverage-collection failures fail
the script.

### RunSnapshotTests.swift

Run the snapshot tests and collect coverage data:

```shell
swift Scripts/RunSnapshotTests.swift
```

The runner generates the iOS test host, executes `xcodebuild test` with coverage enabled, and invokes
`CollectCodeCoverage.swift`. It saves coverage data in `.build/coverage/SnapshotTests/` and test results in
`.build/snapshots/SnapshotTests.xcresult`. Test output goes to standard error. Test or coverage-collection failures
fail the script.

The button snapshot tests compare existing references without recording. Missing or mismatched references fail.
Repository and tutorial assets are excluded. See [Snapshotting](Snapshotting.md) to record updated references.

Run the suites separately in the same checkout. Before rerunning either suite, move its existing result bundle and
coverage directory aside. If collection finds multiple simulator profiles, also move that suite's build directory
under `.build/workflows/` aside.

### GenerateCodeCoverageReport.swift

Use the report generator independently to regenerate a report from existing coverage data without rerunning tests:

```shell
swift Scripts/CollectCodeCoverage.swift --merge .build/coverage
swift Scripts/GenerateCodeCoverageReport.swift \
    --report .build/coverage/Combined/code-coverage.json \
    --sources Sources
```

First run the test runners above. The collector merges coverage from compatible builds of the same source revision,
counting code exercised by both suites once. Move `.build/coverage/Combined/` aside before merging again.
The generator reads the JSON export and reports coverage by target and source file, including package-wide totals.
Only files beneath the supplied source directory are included. It does not run tests or collect coverage itself.

The workflow runs the suites as independent jobs, then generates one report from the successful jobs. It identifies
partial coverage, or reports coverage as unavailable if neither succeeds. Rerunning a failed job and the coverage job
reuses the other job's saved coverage. The workflow appends the report to the GitHub Actions summary and uploads the
coverage artifacts. Test failures still fail the workflow.

## Validation

### ValidateBranchRoute.swift

Check whether a source branch is allowed to target a destination branch:

```shell
swift Scripts/ValidateBranchRoute.swift release/1.0.0 feature/example
```

The first argument is the destination branch; the second is the source branch. Any branch may target `main`.
Release branches accept source branches beginning with `feature/`, `bugfix/`, `chore/`, `docs/`, or `test/`.

### ValidateContributors.swift

Check the contributor file against Git history:

```shell
swift Scripts/ValidateContributors.swift
swift Scripts/ValidateContributors.swift main
```

The script compares `CONTRIBUTORS.txt` against history at `HEAD`, or at the optional revision argument. It honors Git's
mailmap, excludes GitHub bot addresses, and prints a diff when the file needs updating. Use a checkout with complete
history, as the workflow does. Validation does not modify the contributor file.

### ValidatePullRequestTitle.swift

Check a title against the repository's Conventional Commit rules:

```shell
swift Scripts/ValidatePullRequestTitle.swift "feat: Add an example"
```

The title is supplied as one quoted argument. It must contain an allowed type, an optional parenthesized scope and
breaking-change marker, and a description after `: `. Invalid titles produce a diagnostic describing the accepted
format and types.

### ValidateTag.swift

Check a release tag:

```shell
swift Scripts/ValidateTag.swift 1.0.0
```

Tags must use three dot-separated ASCII decimal components, with no leading zeros except for a component equal to
zero. Prefixes, prerelease identifiers, and build metadata are not accepted.
