// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import Foundation
import PackagePlugin

/// Re-records the iOS snapshot references through the standalone recording script.
@main
internal struct BuyMeACoffeeSnapshotsPlugin {}

// MARK: - CommandPlugin

extension BuyMeACoffeeSnapshotsPlugin: CommandPlugin {
    /// Runs the recorder regardless of the package target selected by the invoking IDE.
    ///
    /// - Parameters:
    ///   - context: The package location supplied by SwiftPM.
    ///   - arguments: Options forwarded to the recording script.
    /// - Throws: An error when the script cannot start or does not complete successfully.
    internal func performCommand(
        context: PluginContext,
        arguments: Array<String>
    ) async throws {
        var extractor: ArgumentExtractor = .init(arguments)
        _ = extractor.extractOption(named: "target")

        let packageURL: URL = context.package.directoryURL
        let process: Process = .init()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swift",
            packageURL.appendingPathComponent("Scripts/RecordSnapshots.swift").path
        ] + extractor.remainingArguments
        process.currentDirectoryURL = packageURL

        try process.run()
        process.waitUntilExit()

        guard process.terminationReason == .exit && process.terminationStatus == 0 else {
            throw BuyMeACoffeeSnapshotsPluginError.commandFailed(status: process.terminationStatus)
        }
    }
}
