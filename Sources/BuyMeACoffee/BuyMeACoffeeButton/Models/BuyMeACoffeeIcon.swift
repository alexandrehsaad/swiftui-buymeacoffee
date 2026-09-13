// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

/// Icons used by `BuyMeACoffeeLabel`.
internal enum BuyMeACoffeeIcon {
    /// The coffee icon.
    case coffee

    /// The name of the image resource containing this icon.
    internal var filename: String {
        switch self {
        case .coffee:
            return "buymeacoffee-symbol"
        }
    }
}

// MARK: - Equatable

extension BuyMeACoffeeIcon: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeIcon: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeIcon: Sendable {}
