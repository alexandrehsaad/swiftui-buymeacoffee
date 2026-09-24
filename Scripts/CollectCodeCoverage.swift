// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import CryptoKit
import Foundation

// MARK: - Arguments

/// The operation requested by the coverage collection command.
fileprivate struct Arguments {
    /// A supported coverage operation and its input.
    fileprivate enum Operation {
        /// Collects build output for one test suite.
        ///
        /// - Parameter suite: `UnitTests` or `SnapshotTests`.
        case collect(suite: String)

        /// Merges available suite artifacts beneath a directory.
        ///
        /// - Parameter directory: The path containing the collected coverage directories.
        case merge(directory: String)
    }

    /// The validated operation to perform.
    fileprivate let operation: Operation

    /// Parses the arguments following the script name.
    ///
    /// - Parameter arguments: One operation flag and its suite name or directory.
    /// - Throws: An error if the argument count, flag, or suite name is invalid.
    fileprivate init(_ arguments: Array<String>) throws {
        guard arguments.count == 2 else {
            throw NSError(
                domain: "Usage: CollectCodeCoverage.swift --collect UnitTests|SnapshotTests OR --merge <directory>",
                code: 1
            )
        }
        if arguments[0] == "--collect", ["UnitTests", "SnapshotTests"].contains(arguments[1]) {
            self.operation = .collect(suite: arguments[1])
        } else if arguments[0] == "--merge" {
            self.operation = .merge(directory: arguments[1])
        } else {
            throw NSError(
                domain: "Invalid coverage arguments",
                code: 1
            )
        }
    }
}

// MARK: - CoverageManifest

/// Identifies the source and build configuration that produced a coverage profile.
fileprivate struct CoverageManifest {
    /// The checked-out commit, including the merge commit for pull requests.
    fileprivate let commit: String

    /// A digest of the library sources and package manifest.
    fileprivate let sourceDigest: String

    /// The Xcode version and build number.
    fileprivate let toolchain: String

    /// The absolute source directory encoded in the coverage mapping.
    fileprivate let sourceRoot: String

    /// Creates the compatibility metadata attached to a suite's coverage.
    ///
    /// - Parameters:
    ///   - commit: The checked-out Git revision.
    ///   - sourceDigest: The digest of library sources and package configuration.
    ///   - toolchain: The Xcode version and build number.
    ///   - sourceRoot: The source path encoded in the library mapping.
    fileprivate init(
        commit: String,
        sourceDigest: String,
        toolchain: String,
        sourceRoot: String
    ) {
        self.commit = commit
        self.sourceDigest = sourceDigest
        self.toolchain = toolchain
        self.sourceRoot = sourceRoot
    }
}

// MARK: - Codable

/// Supports saving and loading compatibility metadata beside each suite's coverage artifacts.
extension CoverageManifest: Codable {}

// MARK: - Equatable

/// Compares every compatibility field before profiles from separate test jobs are merged.
extension CoverageManifest: Equatable {}

// MARK: - CodeCoverageCollector

/// Collects suite artifacts and merges compatible profiles into a complete or partial coverage export.
fileprivate struct CodeCoverageCollector {
    /// The repository root used to resolve build paths and run external tools.
    private let packageDirectory: URL

    /// The file manager used to inspect build products and write coverage artifacts.
    private let manager: FileManager

    /// Workflow results and the expected commit, when collection runs in GitHub Actions.
    private let environment: Dictionary<String, String>

    /// Creates a collector for a repository and its execution environment.
    ///
    /// - Parameters:
    ///   - packageDirectory: The repository root containing the sources and build output.
    ///   - manager: The file manager used for artifact operations.
    ///   - environment: Optional CI context; local merging uses available artifact directories instead.
    fileprivate init(
        packageDirectory: URL,
        manager: FileManager = .default,
        environment: Dictionary<String, String> = ProcessInfo.processInfo.environment
    ) {
        self.packageDirectory = packageDirectory.standardizedFileURL
        self.manager = manager
        self.environment = environment
    }

    /// Collects a test suite's raw profile and library coverage mapping for later merging.
    ///
    /// Copies the profile and instrumented library object from the suite's build directory into `.build/coverage`.
    /// A manifest records the current source revision, source digest, Xcode version, and source paths for merge validation.
    /// Run collection from the repository root immediately after the corresponding tests, without changing the sources.
    /// Existing output is preserved; collection fails instead of replacing it.
    ///
    /// - Parameter suite: `UnitTests` or `SnapshotTests`, matching the runner's build directory.
    /// - Throws: An error if build output is missing, ambiguous, or cannot be copied.
    fileprivate func collect(_ suite: String) throws {
        let build: URL = self.packageDirectory.appendingPathComponent(".build/workflows/\(suite)/Build")
        let profileRoot: URL = build.appendingPathComponent("ProfileData")
        let profiles: Array<URL> =
            (self.manager.enumerator(
                at: profileRoot,
                includingPropertiesForKeys: nil
            )?.allObjects as? Array<URL> ?? [])
            .filter { $0.lastPathComponent == "Coverage.profdata" }

        guard profiles.count == 1, let profile = profiles.first else {
            throw NSError(
                domain: "Expected exactly one coverage profile for \(suite); clean its build directory and rerun.",
                code: 1
            )
        }

        let sourceRoot: URL = self.packageDirectory.appendingPathComponent("Sources")
        let library: URL = sourceRoot.appendingPathComponent("BuyMeACoffee")
        let sources: Array<URL> =
            (self.manager.enumerator(
                at: library,
                includingPropertiesForKeys: nil
            )?.allObjects as? Array<URL> ?? [])
            .filter { $0.pathExtension == "swift" }.sorted { $0.path < $1.path }

        // Stable path ordering makes equivalent source checkouts produce the same digest.
        var digest: SHA256 = .init()

        for source in sources + [self.packageDirectory.appendingPathComponent("Package.swift")] {
            digest.update(data: Data(source.path.utf8))
            digest.update(data: try Data(contentsOf: source))
        }

        let manifest: CoverageManifest = .init(
            commit: String(
                decoding: try self.run(["git", "rev-parse", "HEAD"]),
                as: UTF8.self
            ).trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            sourceDigest: digest.finalize().map {
                String(
                    format: "%02x",
                    $0
                )
            }.joined(),
            toolchain: String(
                decoding: try self.run(["xcodebuild", "-version"]),
                as: UTF8.self
            ),
            sourceRoot: sourceRoot.path
        )

        let destination: URL = self.packageDirectory.appendingPathComponent(".build/coverage/\(suite)")

        guard self.manager.fileExists(atPath: destination.path) == false else {
            throw NSError(
                domain: "Coverage output already exists: \(destination.path). Move it aside before collecting again.",
                code: 1
            )
        }

        try self.manager.createDirectory(
            at: destination,
            withIntermediateDirectories: true
        )
        try self.manager.copyItem(
            at: profile,
            to: destination.appendingPathComponent("Coverage.profdata")
        )
        try self.manager.copyItem(
            at: build.appendingPathComponent("Products/Debug-iphonesimulator/BuyMeACoffee.o"),
            to: destination.appendingPathComponent("BuyMeACoffee.o")
        )

        try JSONEncoder().encode(manifest).write(to: destination.appendingPathComponent("manifest.json"))
    }

    /// Merges coverage from successful suites and records whether the report is complete or partial.
    ///
    /// CI downloads only artifacts belonging to successful prerequisite jobs. On a retry, stable artifact names allow
    /// the unchanged successful job's profile to be reused. Profiles are merged afresh, never with a previous report.
    /// `UNIT_TEST_RESULT` and `SNAPSHOT_TEST_RESULT` select only successful CI jobs; without these environment variables,
    /// local collection directories determine which suites are included. `GITHUB_SHA`, when present, must match the inputs.
    ///
    /// Writes `status.md` in the new `Combined` directory for every outcome. When at least one suite is available, also
    /// writes `Coverage.profdata` and `code-coverage.json`. With no available suites, writes only the unavailable status.
    /// Missing artifacts for successful jobs, incompatible inputs, and existing combined output fail the command.
    ///
    /// - Parameter directory: The directory containing available `UnitTests` and `SnapshotTests` artifacts.
    /// - Throws: An error if an expected artifact is missing, incompatible, or cannot be processed.
    fileprivate func merge(_ directory: String) throws {
        let root: URL = .init(
            fileURLWithPath: directory,
            relativeTo: self.packageDirectory
        ).standardizedFileURL
        let suites: Array<(String, String)> = [
            ("UnitTests", "UNIT_TEST_RESULT"), ("SnapshotTests", "SNAPSHOT_TEST_RESULT")
        ]
        var available: Array<URL> = []
        var descriptions: Array<String> = []

        for (suite, variable) in suites {
            let directory: URL = root.appendingPathComponent(suite)
            let exists: Bool = self.manager.fileExists(atPath: directory.appendingPathComponent("manifest.json").path)

            if let result: String = self.environment[variable] {
                if result == "success" {
                    guard exists else {
                        throw NSError(
                            domain: "Missing coverage artifact for successful suite \(suite).",
                            code: 1
                        )
                    }

                    available.append(directory)
                }

                descriptions.append("- \(suite): \(result)\(result == "success" ? " (included)" : " (excluded)")")
            } else {
                if exists == true {
                    available.append(directory)
                }

                descriptions.append("- \(suite): \(exists ? "included" : "unavailable")")
            }
        }

        let output: URL = root.appendingPathComponent("Combined")

        // Prevent stale exports from an earlier local merge appearing beside a new partial or unavailable report.

        guard self.manager.fileExists(atPath: output.path) == false else {
            throw NSError(
                domain: "Combined coverage already exists. Move it aside before generating a new report.",
                code: 1
            )
        }

        try self.manager.createDirectory(
            at: output,
            withIntermediateDirectories: true
        )

        let title: String =
            available.count == 2
            ? "Complete coverage" : (available.isEmpty ? "Coverage unavailable" : "Partial coverage")
        let status: String = "## \(title)\n\n" + descriptions.joined(separator: "\n") + "\n\n"

        try status.write(
            to: output.appendingPathComponent("status.md"),
            atomically: true,
            encoding: .utf8
        )

        guard let firstDirectory = available.first else {
            return
        }

        // Compare every available manifest before passing any profiles to LLVM.
        let decoder: JSONDecoder = .init()
        let first: CoverageManifest = try decoder.decode(
            CoverageManifest.self,
            from: Data(contentsOf: firstDirectory.appendingPathComponent("manifest.json"))
        )

        for directory in available.dropFirst() {
            let manifest: CoverageManifest = try decoder.decode(
                CoverageManifest.self,
                from: Data(contentsOf: directory.appendingPathComponent("manifest.json"))
            )

            guard first == manifest else {
                throw NSError(
                    domain: "Coverage inputs differ in commit, sources, toolchain, or source paths; refusing to merge.",
                    code: 1
                )
            }
        }

        if let expected: String = self.environment["GITHUB_SHA"], first.commit != expected {
            throw NSError(
                domain: "Coverage does not belong to the workflow's checked-out commit.",
                code: 1
            )
        }

        let profile: URL = output.appendingPathComponent("Coverage.profdata")
        let _ = try self.run(
            ["xcrun", "llvm-profdata", "merge", "-sparse"]
                + available.map { $0.appendingPathComponent("Coverage.profdata").path }
                + ["-o", profile.path]
        )

        let data: Data = try self.run([
            "xcrun", "llvm-cov", "export", firstDirectory.appendingPathComponent("BuyMeACoffee.o").path,
            "-instr-profile=\(profile.path)", first.sourceRoot + "/BuyMeACoffee"
        ])

        try data.write(
            to: output.appendingPathComponent("code-coverage.json"),
            options: .atomic
        )
    }

    /// Runs a tool and captures output, preserving diagnostics and failing on an unsuccessful exit.
    ///
    /// - Parameter arguments: The executable followed by its arguments.
    /// - Returns: The tool's standard output.
    /// - Throws: An error if launch or execution fails.
    private func run(_ arguments: Array<String>) throws -> Data {
        let process: Process = .init()
        let pipe: Pipe = .init()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        process.currentDirectoryURL = self.packageDirectory
        process.standardOutput = pipe

        try process.run()

        // Drain output before waiting so a large export cannot fill the pipe and block the child process.
        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationReason == .exit && process.terminationStatus == 0 else {
            throw NSError(
                domain: "Coverage command failed: \(arguments.joined(separator: " "))",
                code: 1
            )
        }

        return data
    }
}

// MARK: - Coverage Collection and Merging

do {
    let arguments: Arguments = try .init(Array(CommandLine.arguments.dropFirst()))
    let collector: CodeCoverageCollector = .init(
        packageDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    )

    switch arguments.operation {
    case .collect(let suite):
        try collector.collect(suite)
    case .merge(let directory):
        try collector.merge(directory)
    }
} catch let error {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(EXIT_FAILURE)
}
