# Snapshotting

Record and verify the iOS button appearances.

## Overview

The `BuyMeACoffeeSnapshotsPlugin` command plugin is the convenient interface for developers, and
`Scripts/RecordSnapshots.swift` is the standalone recording script. Both generate a disposable application under
`.build/snapshots/Host` to render real iOS views, including Dynamic Type and glass button styles.

Recording is an explicit action. Without a filter, the command records both the visual-regression snapshots and the
repository artwork, then verifies the resulting images with recording disabled. Ordinary Xcode tests and continuous
integration compare only the visual-regression references without updating them.

The iOS suite lives in `Tests/BuyMeACoffeeSnapshotTests`. Its `__Snapshots__` directory contains light and dark
references for the system styles, glass styles, custom fonts and colors, and Dynamic Type sizes. The old 
`BuyMeACoffeeTests` snapshot suite has been removed.

`Tests/RepositorySnapshotTests` contains explicitly produced repository artwork. It is a separate target because its
images are deliverables rather than visual-regression references, and the continuous-integration scheme excludes it.

`Package.swift` declares `BuyMeACoffeeSnapshotTests`. The generated host project also defines a native test target
with the same name, pointing to the same Swift source file and reference directory. This native target supplies the
application-host configuration used by the recorder and CI. Declaring a SwiftPM test target does not
configure its host application. Use the host project for recording and comparing these snapshots, particularly
the glass styles that require a host window. The suite is compiled only on iOS; other destinations do not validate the
iOS snapshots.

## Requirements

Use Xcode 26.5 and the iOS 26.5 simulator runtime with an iPhone 17 to reproduce the checked-in references. Install the
runtime in Xcode Settings under Components if necessary. Select that Xcode installation with `xcode-select` or set
`DEVELOPER_DIR` before invoking the command. A physical device and provisioning profile are not needed.

Use Xcode's bundled toolchain (Xcode > Toolchains > Xcode Default). The separately installed Swift.org 6.3.3
toolchain fails to compile SnapshotTesting 1.19.4 with `Attachment` / `Attachable` conformance errors; see
[the upstream issue](https://github.com/pointfreeco/swift-snapshot-testing/issues/1085). Selecting an Xcode installation
for Terminal does not change the toolchain selected inside Xcode. The references were verified with Xcode's bundled
Apple Swift 6.3.2 compiler.

The host requires iOS 26 or later because it includes glass styles. The library's minimum deployment versions are
unchanged. Snapshot images can change with the Xcode version, simulator runtime, display scale, or architecture;
use the same environment locally and in CI. The suite fixes English (United States), light/dark appearance, and
image scale. The current references were recorded on Apple silicon.

## Command Plugin

Run the plugin from the repository root:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots
```

SwiftPM's sandbox must be disabled because Xcode and CoreSimulator use services and storage outside the package
and plugin work directories. The write permission authorizes updating the references; network access lets Xcode
resolve the host's package dependencies. This command is intended for Terminal. Xcode's sandboxed package-command
menu cannot run this recorder.
Selecting a different package target in the plugin menu does not change its permissions.

Record one test from the main suite by passing its function name without parentheses:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots --filter testButtonStyles
```

For a test in another suite, prefix the function with its suite name. Repository artwork lives in its own target and
is included in an unfiltered recording run, but continuous integration does not build or compare it:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots --filter RepositorySnapshots/makeGitHubBanner
```

Use `--destination` to select another installed iOS simulator:

```shell
swift package --disable-sandbox plugin \
    --allow-writing-to-package-directory \
    --allow-network-connections all \
    record-snapshots --destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'
```

The default destination is the one shown above. Do not select a different runtime when updating references intended
for the current CI configuration. Use `record-snapshots --help` for usage information without building or recording.

Review and commit the resulting PNG changes. Recording does not delete obsolete references or commit files. If a
test is renamed or removed, remove its old references when reviewing that change. Do not run two recording commands
at the same time or edit the snapshot views while a recording is in progress.

## Recording Script

The plugin forwards its options to the Swift script. Invoke it directly when a package command is unnecessary:

```shell
swift Scripts/RecordSnapshots.swift
swift Scripts/RecordSnapshots.swift --filter testButtonStyles
swift Scripts/RecordSnapshots.swift --filter RepositorySnapshots/makeGitHubBanner
```

The script first runs `Scripts/GenerateSnapshotHost.swift`, then runs `xcodebuild build-for-testing` once. It creates 
disposable copies of the resulting `.xctestrun` configuration beside the build products, setting 
`SNAPSHOT_TESTING_RECORD` to `all` for recording and `never` for verification. Both runs use the same compiled tests, 
destination, and filter. The normal Xcode comparison scheme is never changed, and no recording compilation flag is 
cached in the build.

SnapshotTesting intentionally reports assertion failures when recording. The script checks Xcode's structured
results and accepts only recording issues, then requires the same tests to pass the comparison run. A build failure,
crash, unknown filter that selects no tests, unexpected assertion, or comparison failure makes the command fail.
Partially recorded images may remain after a failed run; inspect them before committing.

Build products are stored in `.build/snapshots/DerivedData`. Each invocation prints a unique directory beneath
`.build/snapshots/Runs` containing build logs, recording and verification logs, and Xcode result bundles. Open a
result bundle in Xcode for diagnostics. Status messages appear immediately, with elapsed-time updates every ten
seconds while a tool runs. These outputs are ignored by Git.

## Generated Host

No Xcode project or host application source is maintained in the repository. The generator creates them under
`.build/snapshots/Host`, including a comparison-only `SnapshotHost` scheme. It references the original test sources,
so recordings are written to the existing test reference directory. SnapshotTesting uses the revision from
`Package.resolved`. Generated files are only rewritten when their contents change to preserve incremental builds.

The application provides the window needed to capture Liquid Glass. It is disposable: deleting `.build` is safe;
the next recording command recreates it. Do not edit or commit generated files.

To compare without recording (also used by CI):

```shell
xcrun swift Scripts/GenerateSnapshotHost.swift
xcodebuild test \
    -project .build/snapshots/Host/SnapshotHost.xcodeproj \
    -scheme SnapshotHost \
    -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=NO
```

After generation, you can also open that disposable project in Xcode to run comparison tests.

## Continuous Integration

The `Test` workflow uses a macOS runner with Xcode 26.5 to run the iOS host on an iPhone 17 simulator with iOS 26.5.
The runner operating system does not determine the rendering platform: the simulator destination does.

CI generates the host, then invokes Xcode directly and never runs the recording plugin. Missing or changed references 
fail the job, and Xcode results are uploaded for inspection. Update references locally with the recording command, 
review the differences, and commit them with the corresponding change.
