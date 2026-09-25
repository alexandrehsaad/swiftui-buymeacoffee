# Testing

Run tests and inspect code coverage.

## Overview

Unit tests and snapshot tests exercise the package on an iOS simulator. They run independently and contribute to one
coverage report. Snapshot tests check rendered appearances; unit tests check behavior. The report shows which source
code was exercised, not how thoroughly its behavior was asserted.

## Requirements

Use Xcode 26.5 and an iPhone 17 simulator running iOS 26.5. Select that Xcode installation with `xcode-select` or
`DEVELOPER_DIR`. Run commands from the repository root; package resolution may require network access.

Run the suites separately in the same checkout because they share a generated host project. Before rerunning a suite,
move its result bundle and coverage directory aside. If collection finds multiple simulator profiles, also move that
suite's build directory under `.build/workflows/` aside.

## Continuous Integration

The [Tests workflow](/.github/workflows/tests.yml) runs on pushes to `main` and pull requests targeting `main` or
`release/**` when opened, reopened, or updated. New runs cancel superseded runs for the same branch or pull request.

`Run Unit Tests (iOS)` and `Run Snapshot Tests (iOS)` run as separate jobs. Failure in one does not stop the other. Each
successful job uploads coverage data. Both jobs attempt to upload their Xcode results even if tests fail:
`ios-unit-test-results` and `ios-snapshot-test-results`. Open the result bundles in Xcode to inspect failures.

The `Code Coverage` job waits for both jobs and runs even after failures. It merges coverage from successful jobs, marks
a report as partial when only one succeeds, and reports coverage as unavailable when neither succeeds. Its summary and
`code-coverage` artifact contain the combined report. Test failures still fail the overall workflow. Rerunning failed
jobs also reruns the dependent coverage job, which can reuse the successful job's saved coverage.

## Unit Test Runner

[RunUnitTests.swift](/Scripts/RunUnitTests.swift) runs the unit tests and collects their coverage:

```shell
swift Scripts/RunUnitTests.swift
```

The runner generates an iOS test host with `--unit-tests`, runs `xcodebuild test` with coverage enabled, and invokes
[the coverage collector](#code-coverage-collection-script) after success. It takes no arguments. Test output goes to
standard error; test or collection failures fail the script. Results are saved in `.build/snapshots/UnitTests.xcresult`,
with coverage in `.build/coverage/UnitTests/` and build products in `.build/workflows/UnitTests/`.

The shared [test host generation script](/Docs/Snapshotting.md#test-host-generation-script) also supports running the
unit tests from its generated Xcode project. Generate it with `swift Scripts/GenerateTestHost.swift --unit-tests` first.

## Snapshot Test Runner

See [Snapshotting](/Docs/Snapshotting.md#snapshot-test-runner) for the comparison command, recording tools, and
generated host. The snapshot test runner collects successful coverage in `.build/coverage/SnapshotTests/` for the same
reporting path.

## Code Coverage Collection Script

[CollectCodeCoverage.swift](/Scripts/CollectCodeCoverage.swift) collects profiles and binaries from each successful
suite and merges compatible coverage. The runners invoke collection automatically; use these commands only when
collecting an existing successful build manually:

```shell
swift Scripts/CollectCodeCoverage.swift --collect UnitTests
swift Scripts/CollectCodeCoverage.swift --collect SnapshotTests
```

After running either or both suites, merge the available coverage:

```shell
swift Scripts/CollectCodeCoverage.swift --merge .build/coverage
```

The collector checks source revision, source content, source paths, and Xcode compatibility before merging. Code
exercised by both suites counts once. Invalid artifacts and incompatible inputs fail collection or merging. Move
`.build/coverage/Combined/` aside before merging again. Use coverage from the same source revision, without editing
sources between runs.

The merge writes `status.md` under `.build/coverage/Combined/`. When coverage is available, it also writes the merged
profile and `code-coverage.json`. With neither suite available, it writes only the unavailable status.

## Code Coverage Report Script

[GenerateCodeCoverageReport.swift](/Scripts/GenerateCodeCoverageReport.swift) reads the merged JSON and prints a
Markdown report by target and source file, including package-wide totals. Only files under the supplied source directory
are included. It does not run tests or collect coverage. Invalid input fails the script.

```shell
swift Scripts/GenerateCodeCoverageReport.swift \
    --report .build/coverage/Combined/code-coverage.json \
    --sources Sources
```

Run this after a merge that produced `code-coverage.json`. To save the status and report together as CI does:

```shell
cat .build/coverage/Combined/status.md > .build/coverage/Combined/code-coverage.md
swift Scripts/GenerateCodeCoverageReport.swift \
    --report .build/coverage/Combined/code-coverage.json \
    --sources Sources >> .build/coverage/Combined/code-coverage.md
```
