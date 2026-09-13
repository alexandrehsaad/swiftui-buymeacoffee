// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

// MARK: - RecordingError

/// A diagnostic from the recording script.
fileprivate struct RecordingError: Error, CustomStringConvertible {
    /// Human-readable failure details, including a diagnostic log path when available.
    fileprivate let description: String
}

// MARK: - RecordingArguments

/// Options accepted by both the standalone script and the command plugin.
fileprivate struct RecordingArguments {
    /// Command syntax, default destination, and requirements shown by the help option.
    fileprivate static let usage: String = """
        Usage: swift Scripts/RecordSnapshots.swift [--destination <destination>] [--filter <test-filter>]
        Re-records the iOS snapshots, then verifies the new references with recording disabled.
        Default destination: platform=iOS Simulator,name=iPhone 17,OS=26.5
        Example filter: testButtonStyles
        Repository asset: RepositorySnapshotTests/makeReadMeBanner
        Requires Xcode 26 or later and an installed iOS 26 or later simulator runtime.
        Use --help to display this message without building or recording.
        """

    /// Xcode simulator destination used for both recording and verification.
    fileprivate var destination: String = "platform=iOS Simulator,name=iPhone 17,OS=26.5"
    /// Optional test function or suite-qualified test function; `nil` runs every snapshot suite.
    fileprivate var filter: String?
    /// Whether to print usage information without generating, building, or running tests.
    fileprivate var showsHelp: Bool = false

    /// Parses the options forwarded by the plugin or supplied directly to the script.
    ///
    /// - Parameter arguments: Command-line arguments excluding the executable name.
    /// - Throws: `RecordingError` for unknown, duplicate, incomplete, or invalid options.
    fileprivate init(_ arguments: Array<String>) throws {
        if arguments == ["--help"] || arguments == ["-h"] {
            self.showsHelp = true
            return
        }

        var seen: Set<String> = []
        var index: Int = 0
        while index < arguments.count {
            let option: String = arguments[index]
            guard index + 1 < arguments.count, seen.insert(option).inserted else {
                throw RecordingError(description: Self.usage)
            }
            let value: String = arguments[index + 1]
            switch option {
            case "--destination":
                guard value.split(separator: ",").contains("platform=iOS Simulator") else {
                    throw RecordingError(description: "Only an iOS Simulator destination is supported.")
                }
                self.destination = value
            case "--filter":
                let components: Array<Substring> = value.split(separator: "/", omittingEmptySubsequences: false)
                guard (1...2).contains(components.count), components.allSatisfy({ component in
                    !component.isEmpty && component.allSatisfy({
                        $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_")
                    })
                })
                else {
                    throw RecordingError(
                        description: "Use a test function or SuiteName/testFunction, without parentheses."
                    )
                }
                self.filter = value
            default:
                throw RecordingError(description: "Unknown option: \(option)\n\(Self.usage)")
            }
            index += 2
        }
    }
}

/// Writes a progress line directly to standard error without Swift's standard-output buffering.
///
/// The invoking process may still buffer or group the output before displaying it.
///
/// - Parameter message: Status text to emit with a trailing newline.
fileprivate func reportProgress(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

// MARK: - ProcessRunner

/// Runs Xcode tools with argument arrays, preserving their output in a log or capturing structured data.
fileprivate enum ProcessRunner {
    /// Runs a tool synchronously, saving its combined output and reporting elapsed time.
    ///
    /// - Parameters:
    ///   - arguments: Tool name followed by arguments to pass through `xcrun`.
    ///   - workingDirectoryURL: Directory in which the child process executes.
    ///   - logURL: File to create for the tool's standard output and standard error.
    /// - Returns: The exit status, including nonzero statuses for the caller to interpret.
    /// - Throws: File or process-launch errors, or `RecordingError` if a signal terminates the tool.
    fileprivate static func run(
        arguments: Array<String>,
        workingDirectoryURL: URL,
        logURL: URL
    ) throws -> Int32 {
        FileManager.default.createFile(atPath: logURL.path, contents: nil)
        let output: FileHandle = try .init(forWritingTo: logURL)
        defer { try? output.close() }

        let process: Process = Self.process(arguments: arguments, workingDirectoryURL: workingDirectoryURL)
        process.standardOutput = output
        process.standardError = output
        reportProgress("Log: \(logURL.path)")
        let started = Date()
        try process.run()
        var nextUpdate = 10
        while process.isRunning {
            Thread.sleep(forTimeInterval: 0.25)
            let elapsed = Int(Date().timeIntervalSince(started))
            if elapsed >= nextUpdate {
                let operation: String = logURL.deletingPathExtension().lastPathComponent
                reportProgress("Still running \(operation)… \(elapsed)s elapsed")
                nextUpdate = elapsed + 10
            }
        }
        process.waitUntilExit()
        guard process.terminationReason == .exit else {
            throw RecordingError(description: "Xcode was interrupted. See \(logURL.path)")
        }
        return process.terminationStatus
    }

    /// Captures a successful tool's standard output as data, leaving standard error visible.
    ///
    /// - Parameters:
    ///   - arguments: Tool name and arguments to pass through `xcrun`.
    ///   - workingDirectoryURL: Directory in which the child process executes.
    /// - Returns: The complete standard-output data, suitable for structured result parsing.
    /// - Throws: A launch error, or `RecordingError` if the tool does not exit successfully.
    fileprivate static func output(
        arguments: Array<String>,
        workingDirectoryURL: URL
    ) throws -> Data {
        let pipe: Pipe = .init()
        let process: Process = Self.process(arguments: arguments, workingDirectoryURL: workingDirectoryURL)
        process.standardOutput = pipe
        try process.run()
        // Drain the pipe before waiting so a full output buffer cannot block the child.
        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationReason == .exit && process.terminationStatus == 0 else {
            throw RecordingError(
                description: "Could not read the Xcode test results (status \(process.terminationStatus))."
            )
        }
        return data
    }

    /// Configures an unstarted process using the selected Xcode installation's tools.
    ///
    /// - Parameters:
    ///   - arguments: Tool name and individual arguments; no shell interpretation is performed.
    ///   - workingDirectoryURL: Working directory for the child process.
    /// - Returns: A process ready for output configuration and launch.
    private static func process(
        arguments: Array<String>,
        workingDirectoryURL: URL
    ) -> Process {
        let process: Process = .init()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = arguments
        process.currentDirectoryURL = workingDirectoryURL
        return process
    }
}

// MARK: - SnapshotRecorder

/// Generates and builds the iOS host, records references, and checks them using the same build.
fileprivate struct SnapshotRecorder {
    /// Repository root containing the scripts, package manifest, tests, and reference images.
    fileprivate let packageURL: URL
    /// Validated destination and optional test filter for this invocation.
    fileprivate let arguments: RecordingArguments
    /// Test target to generate, record, and verify.
    fileprivate let testTargetName: String

    /// Generates the host, builds once, records references, and verifies the same tests.
    ///
    /// Logs and result bundles remain in a unique run directory. Disposable test configurations
    /// are removed on exit; reference images already written are retained even if verification fails.
    ///
    /// - Throws: Generation, build, filesystem, result-parsing, or test-validation errors.
    fileprivate func run() throws {
        let manager: FileManager = .default
        let workURL: URL = self.packageURL.appendingPathComponent(".build/snapshots")
        let buildURL: URL = workURL.appendingPathComponent("DerivedData")
        let runURL: URL = workURL.appendingPathComponent("Runs/\(UUID().uuidString)")
        try manager.createDirectory(at: runURL, withIntermediateDirectories: true)
        reportProgress("Snapshot target: \(self.testTargetName)")
        reportProgress("Snapshot destination: \(self.arguments.destination)")
        reportProgress("Logs and results: \(runURL.path)")

        reportProgress("Generating the iOS snapshot host…")
        var generationArguments: Array<String> = [
            "swift", self.packageURL.appendingPathComponent("Scripts/GenerateSnapshotHost.swift").path
        ]
        if self.testTargetName == "RepositorySnapshotTests" {
            generationArguments.append("--repository-snapshots")
        }
        let generationStatus = try ProcessRunner.run(
            arguments: generationArguments,
            workingDirectoryURL: self.packageURL,
            logURL: runURL.appendingPathComponent("generate.log")
        )
        guard generationStatus == 0 else {
            throw RecordingError(description: "Could not generate the snapshot host. See \(runURL.path)/generate.log")
        }

        // The generated project can change its package-product references between runs. Reusing Xcode's
        // build description in that case leaves the products unresolved even though both packages exist.
        if manager.fileExists(atPath: buildURL.path) {
            try manager.removeItem(at: buildURL)
        }

        let projectURL = workURL.appendingPathComponent("Host/SnapshotHost.xcodeproj")
        let buildLogURL: URL = runURL.appendingPathComponent("build.log")
        reportProgress("Building the iOS snapshot host…")
        let buildStatus: Int32 = try ProcessRunner.run(
            arguments: [
                "xcodebuild", "build-for-testing",
                "-project", projectURL.path,
                "-scheme", "SnapshotHost",
                "-destination", self.arguments.destination,
                "-derivedDataPath", buildURL.path,
                "-clonedSourcePackagesDirPath", workURL.appendingPathComponent("PackageCache").path,
                "CODE_SIGNING_ALLOWED=NO"
            ],
            workingDirectoryURL: self.packageURL,
            logURL: buildLogURL
        )
        guard buildStatus == 0 else {
            let log: String = (try? String(contentsOf: buildLogURL, encoding: .utf8)) ?? ""
            let errors: Array<String> = log.components(separatedBy: .newlines).filter {
                $0.contains("error:")
            }
            let detail: String = errors.suffix(4).joined(separator: "\n")
            throw RecordingError(description: """
                The iOS snapshot host could not build.
                \(detail)

                If launched from Xcode's package-command menu, the plugin is sandboxed and cannot run this recorder.
                Use the Terminal plugin with --disable-sandbox.
                For automatic recording and verification, use the Terminal command documented in Docs/Snapshotting.md.
                Full build log: \(buildLogURL.path)
                """
            )
        }

        let productsURL: URL = buildURL.appendingPathComponent("Build/Products")
        let plans: Array<URL> = try manager.contentsOfDirectory(
            at: productsURL,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ).filter { $0.lastPathComponent.hasPrefix("SnapshotHost_") && $0.pathExtension == "xctestrun" }
        // Cached builds can retain configurations for other architectures or SDK versions.
        let planURL: URL? = try plans.sorted {
            let first: Date =
                try $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast
            let second: Date =
                try $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast
            return first > second
        }.first
        guard let planURL else {
            throw RecordingError(description: "Xcode produced no test-run configuration. See \(buildLogURL.path)")
        }

        // Keep copies beside the original so Xcode's __TESTROOT__ paths remain valid.
        let recordingPlanURL: URL = productsURL.appendingPathComponent("record-\(runURL.lastPathComponent).xctestrun")
        let verificationPlanURL: URL = productsURL.appendingPathComponent(
            "verify-\(runURL.lastPathComponent).xctestrun"
        )
        defer {
            try? manager.removeItem(at: recordingPlanURL)
            try? manager.removeItem(at: verificationPlanURL)
        }
        try self.writePlan(sourceURL: planURL, destinationURL: recordingPlanURL, record: "all")
        try self.writePlan(sourceURL: planURL, destinationURL: verificationPlanURL, record: "never")

        reportProgress("Recording references… (recording assertions are expected to fail)")
        let recordResultURL: URL = runURL.appendingPathComponent("Record.xcresult")
        let recordStatus: Int32 = try self.test(planURL: recordingPlanURL, resultURL: recordResultURL)
        let recordSummary: Dictionary<String, Any> = try self.result(arguments: ["summary"], resultURL: recordResultURL)
        let failures: Array<Dictionary<String, Any>> =
            recordSummary["testFailures"] as? Array<Dictionary<String, Any>> ?? []
        let failedTestCount: Int = recordSummary["failedTests"] as? Int ?? 0
        let passedTestCount: Int = recordSummary["passedTests"] as? Int ?? 0
        let testCount: Int = recordSummary["totalTestCount"] as? Int ?? 0
        // Recording assertions fail, but tests without snapshots can pass normally.
        // Require at least one recording test and inspect every failure below; exit 65 alone is insufficient.
        guard recordStatus == 65, failedTestCount > 0,
            testCount == failedTestCount + passedTestCount,
            failures.count == failedTestCount
        else {
            throw RecordingError(description:
                "Recording did not execute the expected snapshot tests. Check the filter and \(recordResultURL.path)"
            )
        }

        // Recording intentionally fails assertions. Accept only recording issues, including every issue within a test.
        var snapshotCount: Int = 0
        for failure in failures {
            guard let identifier: String = failure["testIdentifierString"] as? String else {
                throw RecordingError(
                    description: "Xcode returned an unrecognized test failure. See \(recordResultURL.path)"
                )
            }
            let details: Dictionary<String, Any> = try self.result(
                arguments: ["test-details", "--test-id", identifier],
                resultURL: recordResultURL
            )
            let issues: Array<String> = Self.failureMessages(in: details)
            guard !issues.isEmpty,
                issues.allSatisfy({
                    $0.hasPrefix("Issue recorded: Record mode is on. Automatically recorded snapshot:")
                })
            else {
                throw RecordingError(
                    description:
                        "Recording encountered a real test failure in \(identifier). See \(recordResultURL.path)"
                )
            }
            snapshotCount += issues.count
        }

        reportProgress("Verifying \(snapshotCount) recorded snapshots…")
        let verifyResultURL: URL = runURL.appendingPathComponent("Verify.xcresult")
        let verifyStatus: Int32 = try self.test(planURL: verificationPlanURL, resultURL: verifyResultURL)
        let verifySummary: Dictionary<String, Any> = try self.result(arguments: ["summary"], resultURL: verifyResultURL)
        // A successful run selecting fewer tests must not count as complete verification.
        guard verifyStatus == 0, verifySummary["passedTests"] as? Int == testCount,
            verifySummary["totalTestCount"] as? Int == testCount,
            verifySummary["failedTests"] as? Int == 0
        else {
            throw RecordingError(
                description: "The new references did not pass verification. See \(verifyResultURL.path)"
            )
        }
        reportProgress("Recorded and verified \(snapshotCount) snapshots across \(testCount) test functions.")
        let referencesURL: URL = self.packageURL
            .appendingPathComponent("Tests/\(self.testTargetName)/__Snapshots__")
        reportProgress(
            "References: \(referencesURL.path)"
        )
    }

    /// Copies a test-run configuration with an explicit recording mode for its single test target.
    ///
    /// - Parameters:
    ///   - sourceURL: Xcode-generated `.xctestrun` property list to read without backporting it.
    ///   - destinationURL: Disposable copy beside the build products, preserving relative paths.
    ///   - record: SnapshotTesting recording mode: `all` to replace images or `never` to compare.
    /// - Throws: Property-list or filesystem errors, or `RecordingError` unless exactly one target is found.
    private func writePlan(sourceURL: URL, destinationURL: URL, record: String) throws {
        let original: Any = try PropertyListSerialization.propertyList(from: Data(contentsOf: sourceURL), format: nil)
        var targetCount: Int = 0
        /// Recursively updates target environments across flat and nested test-run formats.
        ///
        /// Each target dictionary increments `targetCount`; unrelated property-list values are preserved.
        ///
        /// - Parameter value: A dictionary, array, or scalar from the original property list.
        /// - Returns: The corresponding value with the recording environment applied to test targets.
        func update(_ value: Any) -> Any {
            if var dictionary = value as? Dictionary<String, Any> {
                if dictionary["TestBundlePath"] != nil {
                    var environment: Dictionary<String, String> =
                        dictionary["EnvironmentVariables"] as? Dictionary<String, String> ?? [:]
                    environment["SNAPSHOT_TESTING_RECORD"] = record
                    dictionary["EnvironmentVariables"] = environment
                    targetCount += 1
                    return dictionary
                }
                return dictionary.mapValues { update($0) }
            }
            if let array = value as? Array<Any> { return array.map { update($0) } }
            return value
        }
        let updated: Any = update(original)
        guard targetCount == 1 else {
            throw RecordingError(description: "Expected one iOS snapshot target, found \(targetCount).")
        }
        let data: Data = try PropertyListSerialization.data(fromPropertyList: updated, format: .xml, options: 0)
        try data.write(to: destinationURL, options: .atomic)
    }

    /// Runs the previously built tests on the configured simulator with optional function filtering.
    ///
    /// - Parameters:
    ///   - planURL: Disposable test-run configuration selecting recording or comparison mode.
    ///   - resultURL: Destination for the result bundle; a sibling `.log` stores tool output.
    /// - Returns: Xcode's exit status for the caller to validate against the result bundle.
    /// - Throws: Log-file, launch, or process-interruption errors.
    private func test(planURL: URL, resultURL: URL) throws -> Int32 {
        var options: Array<String> = [
            "xcodebuild", "test-without-building",
            "-xctestrun", planURL.path,
            "-destination", self.arguments.destination,
            "-parallel-testing-enabled", "NO",
            "-resultBundlePath", resultURL.path
        ]
        if let filter = self.arguments.filter {
            let components: Array<Substring> = filter.split(separator: "/")
            let suite: Substring = components.count == 2 ? components[0] : "BuyMeACoffeeButtonSnapshotTests"
            let function: Substring = components[components.count - 1]
            options += ["-only-testing:\(self.testTargetName)/\(suite)/\(function)()"]
        }
        return try ProcessRunner.run(
            arguments: options,
            workingDirectoryURL: self.packageURL,
            logURL: resultURL.deletingPathExtension().appendingPathExtension("log")
        )
    }

    /// Reads a structured test summary or individual test details from an Xcode result bundle.
    ///
    /// - Parameters:
    ///   - arguments: Subcommand and options following `xcresulttool get test-results`.
    ///   - resultURL: Completed result bundle to inspect.
    /// - Returns: The decoded JSON object containing the requested test results.
    /// - Throws: Tool execution or JSON decoding errors, or `RecordingError` for a non-object response.
    private func result(arguments: Array<String>, resultURL: URL) throws -> Dictionary<String, Any> {
        let data: Data = try ProcessRunner.output(
            arguments: ["xcresulttool", "get", "test-results"] + arguments + ["--path", resultURL.path],
            workingDirectoryURL: self.packageURL
        )
        guard let result = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, Any> else {
            throw RecordingError(description: "Xcode returned an invalid result summary.")
        }
        return result
    }

    /// Extracts failed test-run messages from the nested result-detail tree.
    ///
    /// Traversal stops at each failed test-run node to avoid also counting its descendants.
    /// Missing names produce a fallback message that will fail the recording-only validation.
    ///
    /// - Parameter value: A decoded JSON dictionary, array, or scalar from test details.
    /// - Returns: Failure messages used to distinguish recording assertions from unexpected failures.
    private static func failureMessages(in value: Any) -> Array<String> {
        if let dictionary = value as? Dictionary<String, Any> {
            if dictionary["nodeType"] as? String == "Test Case Run", dictionary["result"] as? String == "Failed" {
                return [dictionary["name"] as? String ?? "Unknown failure"]
            }
            return dictionary.values.flatMap { Self.failureMessages(in: $0) }
        }
        if let array = value as? Array<Any> { return array.flatMap { Self.failureMessages(in: $0) } }
        return []
    }
}

// MARK: - Recording

// Resolve the repository from this script rather than the caller's working directory.
do {
    let arguments: RecordingArguments = try .init(Array(CommandLine.arguments.dropFirst()))
    if arguments.showsHelp {
        reportProgress(RecordingArguments.usage)
    } else {
        let packageURL: URL = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let repositoryTarget = "RepositorySnapshotTests"
        let comparisonTarget = "BuyMeACoffeeSnapshotTests"
        if arguments.filter == nil {
            try SnapshotRecorder(
                packageURL: packageURL,
                arguments: arguments,
                testTargetName: comparisonTarget
            ).run()
            try SnapshotRecorder(
                packageURL: packageURL,
                arguments: arguments,
                testTargetName: repositoryTarget
            ).run()
        } else {
            let targetName: String = ["RepositorySnapshotTests/", "TutorialSnapshotTests/"].contains {
                arguments.filter?.hasPrefix($0) == true
            }
                ? repositoryTarget
                : comparisonTarget
            try SnapshotRecorder(
                packageURL: packageURL,
                arguments: arguments,
                testTargetName: targetName
            ).run()
        }
    }
} catch {
    FileHandle.standardError.write(Data("Snapshot recording failed: \(error)\n".utf8))
    exit(1)
}
