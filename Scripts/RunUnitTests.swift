// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

// MARK: - UnitTestRunnerError

/// An error produced while validating inputs or running a command.
fileprivate enum UnitTestRunnerError {
    /// Unsupported command-line arguments were supplied.
    case invalidArguments

    /// A process could not be started.
    ///
    /// - Parameter underlyingError: The original process-launch error.
    case launchFailed(underlyingError: any Error)

    /// A command exited unsuccessfully.
    ///
    /// - Parameter status: The command's exit status.
    case commandFailed(status: Int32)

    /// A command was terminated by a signal.
    ///
    /// - Parameter signal: The terminating signal.
    case commandInterrupted(signal: Int32)

    /// The command-line status, preserving unsuccessful subprocess exit codes.
    fileprivate var exitStatus: Int32 {
        switch self {
        case .commandFailed(let status):
            return status
        default:
            return EXIT_FAILURE
        }
    }
}

// MARK: - CustomStringConvertible

extension UnitTestRunnerError: CustomStringConvertible {
    fileprivate var description: String {
        switch self {
        case .invalidArguments:
            return "Usage: RunUnitTests.swift"
        case .launchFailed(let underlyingError):
            return "Could not start command: \(underlyingError)"
        case .commandFailed(let status):
            return "Command failed with exit status \(status)."
        case .commandInterrupted(let signal):
            return "Command was terminated by signal \(signal)."
        }
    }
}

// MARK: - Error

extension UnitTestRunnerError: Error {}

// MARK: - Arguments

/// The command-line arguments accepted by the test runner.
fileprivate struct Arguments {
    /// Validates that no options were supplied.
    ///
    /// - Parameter arguments: Arguments following the script name.
    /// - Throws: `UnitTestRunnerError.invalidArguments` if any options are supplied.
    fileprivate init(_ arguments: Array<String>) throws(UnitTestRunnerError) {
        guard arguments.isEmpty else {
            throw UnitTestRunnerError.invalidArguments
        }
    }
}

// MARK: - UnitTestRunner

/// Runs unit tests and collects coverage artifacts for local use and continuous integration.
fileprivate struct UnitTestRunner {
    /// Creates a unit tests runner.
    fileprivate init() {}

    /// Generates the iOS test host, runs unit tests with coverage enabled, and collects their coverage.
    ///
    /// Run this script from the repository root. Test output is directed to standard error.
    /// Existing result bundles and coverage directories must be moved aside before rerunning.
    /// Subprocess failures terminate the script with the same exit status; signals result in a failure status.
    /// Coverage is collected only after the tests succeed and can then be merged with the other suite's coverage.
    ///
    /// - Throws: `UnitTestRunnerError` if a subprocess cannot start or complete successfully.
    fileprivate func run() throws(UnitTestRunnerError) {
        try self.runXcrun(arguments: ["swift", "Scripts/GenerateTestHost.swift", "--unit-tests"])

        try self.runXcrun(arguments: [
            "xcodebuild", "test",
            "-project", ".build/tests/Host/TestHost.xcodeproj",
            "-scheme", "TestHost",
            "-derivedDataPath", ".build/workflows/UnitTests",
            "-destination", "platform=iOS Simulator,name=iPhone 17,OS=26.5",
            "-parallel-testing-enabled", "NO",
            "-resultBundlePath", ".build/snapshots/UnitTests.xcresult",
            "-enableCodeCoverage", "YES",
            "CODE_SIGNING_ALLOWED=NO"
        ])

        try self.runXcrun(arguments: ["swift", "Scripts/CollectCodeCoverage.swift", "--collect", "UnitTests"])
    }

    /// Runs a command using the selected Xcode toolchain, forwarding its output to standard error.
    ///
    /// - Parameter arguments: The tool name and arguments passed to `xcrun`.
    /// - Throws: `UnitTestRunnerError` if the process cannot start or complete successfully.
    private func runXcrun(arguments: Array<String>) throws(UnitTestRunnerError) {
        let process: Process = .init()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["xcrun"] + arguments
        process.standardOutput = FileHandle.standardError

        do {
            try process.run()
        } catch let error {
            throw UnitTestRunnerError.launchFailed(underlyingError: error)
        }

        process.waitUntilExit()

        guard process.terminationReason == .exit else {
            throw UnitTestRunnerError.commandInterrupted(signal: process.terminationStatus)
        }
        guard process.terminationStatus == EXIT_SUCCESS else {
            throw UnitTestRunnerError.commandFailed(status: process.terminationStatus)
        }
    }
}

// MARK: - Test Execution

do throws(UnitTestRunnerError) {
    let _: Arguments = try .init(Array(CommandLine.arguments.dropFirst()))
    let runner: UnitTestRunner = .init()
    try runner.run()
} catch let error {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(error.exitStatus)
}
