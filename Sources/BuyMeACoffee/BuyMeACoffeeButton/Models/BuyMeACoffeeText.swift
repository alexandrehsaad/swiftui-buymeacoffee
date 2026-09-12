// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import Foundation

/// Localized wording used by `BuyMeACoffeeLabel`.
internal enum BuyMeACoffeeText: String {
    /// The coffee text.
    case coffee = "buymeacoffee.label.coffee"

    /// The localized resource for this wording.
    internal var localizedStringResource: LocalizedStringResource {
        return .init(
            .init(self.rawValue),
            bundle: .module
        )
    }
}

// MARK: - Equatable

extension BuyMeACoffeeText: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeText: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeText: Sendable {}
