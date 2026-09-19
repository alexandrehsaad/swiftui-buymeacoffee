# Snapshotting

Record and verify the button appearances.

## Overview

Buy Me a Coffee provides a command plugin for recording snapshots and a standalone recording script. Both generate a
temporary iOS application to render the button styles, including Liquid Glass. A separate host-generation script 
prepares the same application for comparisons without recording.

Recording is an explicit action. Without a filter, the recorder updates both the button reference images and repository
artwork, then verifies the resulting images with recording disabled. Comparison runs check existing references without
modifying them.

Button references live in `Tests/BuyMeACoffeeSnapshotTests/__Snapshots__`. Repository artwork is produced by
`Tests/RepositorySnapshotTests` and is excluded from CI comparisons. Review recorded PNG changes before committing them
with the corresponding source changes.

## Requirements

Use Xcode 26.5 with its bundled Swift 6.3.2 toolchain and an iPhone 17 simulator running iOS 26.5 to match CI. Install
the runtime and create the simulator in Xcode if needed. Select the Xcode installation with `xcode-select` or
`DEVELOPER_DIR` before running the commands.

## Command Plugin

The `BuyMeACoffeeSnapshotsPlugin` command plugin records snapshots and verifies them on the iOS simulator. Run it from
Terminal: Xcode's package-command menu keeps the plugin sandboxed, preventing access to services and storage required by
Xcode and CoreSimulator. The Terminal command uses `--disable-sandbox` to allow this access.

Run the plugin from the repository root:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots
```

The write permission authorizes updating reference images; network access lets Xcode resolve the host's package
dependencies.

Record one test from the main suite by passing its function name without parentheses:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots --filter testButtonStyles
```

For a test in another suite, prefix the function with its suite name. Repository artwork lives in its own target and is
included in an unfiltered recording run, but continuous integration does not build or compare it:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots --filter RepositorySnapshotTests/makeReadMeBanner
```

Use `--destination` to select another installed iOS simulator:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots --destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'
```

The default destination is the one shown above. Do not select a different runtime when updating references intended for
the current CI configuration. Use `record-snapshots --help` for usage information without building or recording.

Review and commit the resulting PNG changes. Recording does not delete obsolete references or commit files. If a test is
renamed or removed, remove its old references when reviewing that change. Do not run two recording commands at the same
time or edit the snapshot views while a recording is in progress.

## Recording Script

The plugin forwards its options to the Swift script. Invoke it directly when a package command is unnecessary:

```shell
swift Scripts/RecordSnapshots.swift
swift Scripts/RecordSnapshots.swift --filter testButtonStyles
swift Scripts/RecordSnapshots.swift --filter RepositorySnapshotTests/makeReadMeBanner
```

The script generates the host application, builds the selected tests, records images, and runs the same tests again with
recording disabled. Both runs use the same compiled tests, destination, and filter.

SnapshotTesting intentionally reports “Record mode is on” assertion failures in `Record.xcresult`. The script accepts
these recording failures and requires the subsequent comparison in `Verify.xcresult` to pass. Build failures, unexpected
assertions, and comparison failures stop the command. Partially recorded images may remain after a failed run.

Each invocation prints a directory under `.build/snapshots/Runs` containing logs and Xcode result bundles. Open the
result bundles in Xcode to inspect failures. Generated build files and logs are ignored by Git.

`Scripts/GenerateSnapshotHost.swift` creates the temporary project under `.build/snapshots/Host`. Its `SnapshotHost`
scheme supplies the application needed to render the button styles. Generate the project and run comparisons without
updating references:

```shell
xcrun swift Scripts/GenerateSnapshotHost.swift
xcodebuild test \
    -project .build/snapshots/Host/SnapshotHost.xcodeproj \
    -scheme SnapshotHost \
    -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=NO
```

After generation, you can also open `SnapshotHost.xcodeproj` in Xcode, select the `SnapshotHost` scheme and matching
simulator, and use Product > Test. Use this project rather than testing the package directly so the host application is
configured. Do not edit or commit the generated project.

## Continuous Integration

The `Snapshot` workflow compares existing references using Xcode 26.5 and an iPhone 17 simulator running iOS 26.5. It
runs on pushes to `main` and when pull requests targeting `main` or `release/**` are opened, reopened, or updated with
commits. Superseded runs for the same branch or pull request are cancelled.

CI generates the host and invokes Xcode directly without running the recording plugin. Missing references and images
outside the comparison tolerance fail the job. Download the `ios-snapshot-results` artifact and open `CI.xcresult` in
Xcode to inspect failures. Update references locally, review the differences, and commit them with the corresponding
changes.
