// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

extension URL {
    /// Creates the URL for a Buy Me a Coffee account.
    ///
    /// - Parameter username: The account name appended to the Buy Me a Coffee website URL.
    /// - Returns: The URL for the specified Buy Me a Coffee account.
    internal static func buyMeACoffee(username: String) -> Self {
        guard let url: Self = .init(string: "https://www.buymeacoffee.com/\(username)") else {
            preconditionFailure("Could not construct the Buy Me a Coffee account URL.")
        }
        return url
    }
}
