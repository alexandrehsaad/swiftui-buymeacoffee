// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

/// A recording command that did not finish successfully.
internal enum BuyMeACoffeeSnapshotsPluginError {
    /// Indicates that the recording script exited unsuccessfully or was terminated by a signal.
    ///
    /// - Parameter status: The script process's exit code or terminating signal number.
    case commandFailed(status: Int32)
}

// MARK: - CustomStringConvertible

extension BuyMeACoffeeSnapshotsPluginError: CustomStringConvertible {
    internal var description: String {
        switch self {
        case .commandFailed(let status):
            return "Snapshot recording failed with status \(status). See the recorder's diagnostics."
        }
    }
}

// MARK: - Error

extension BuyMeACoffeeSnapshotsPluginError: Error {}
