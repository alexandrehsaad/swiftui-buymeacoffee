// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

/// Runs snapshot tests and collects coverage artifacts for local use and continuous integration.
fileprivate struct SnapshotTestRunner {
    /// Creates a snapshot tests runner.
    fileprivate init() {}

    /// Generates the iOS test host, runs snapshot tests with coverage enabled, and collects their coverage.
    ///
    /// Run this script from the repository root. Test output is directed to standard error.
    /// Existing result bundles and coverage directories must be moved aside before rerunning.
    /// Subprocess failures terminate the script with the same exit status; signals result in a failure status.
    /// Coverage is collected only after the tests succeed and can then be merged with the other suite's coverage.
    ///
    /// - Throws: An error if a subprocess cannot be launched.
    fileprivate func run() throws {
        guard CommandLine.arguments.count == 1 else {
            FileHandle.standardError.write(Data("Usage: RunSnapshotTests.swift\n".utf8))
            exit(EXIT_FAILURE)
        }

        try self.runXcrun(arguments: ["swift", "Scripts/GenerateTestHost.swift"])

        try self.runXcrun(arguments: [
            "xcodebuild", "test",
            "-project", ".build/tests/Host/TestHost.xcodeproj",
            "-scheme", "TestHost",
            "-derivedDataPath", ".build/workflows/SnapshotTests",
            "-destination", "platform=iOS Simulator,name=iPhone 17,OS=26.5",
            "-parallel-testing-enabled", "NO",
            "-resultBundlePath", ".build/snapshots/SnapshotTests.xcresult",
            "-enableCodeCoverage", "YES",
            "CODE_SIGNING_ALLOWED=NO"
        ])

        try self.runXcrun(arguments: ["swift", "Scripts/CollectCodeCoverage.swift", "--collect", "SnapshotTests"])
    }

    /// Runs a command using the selected Xcode toolchain, forwarding its output to standard error.
    ///
    /// - Parameter arguments: The tool name and arguments passed to `xcrun`.
    /// - Throws: An error if the process cannot be launched.
    private func runXcrun(arguments: Array<String>) throws {
        let process: Process = .init()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["xcrun"] + arguments
        process.standardOutput = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        guard process.terminationReason == .exit && process.terminationStatus == EXIT_SUCCESS else {
            exit(process.terminationReason == .exit ? process.terminationStatus : EXIT_FAILURE)
        }
    }
}

do {
    try SnapshotTestRunner().run()
} catch let error {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(EXIT_FAILURE)
}
