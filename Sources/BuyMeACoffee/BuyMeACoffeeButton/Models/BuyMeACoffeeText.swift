// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import Foundation

/// Localized wording used by `BuyMeACoffeeLabel`.
internal enum BuyMeACoffeeText: String {
    /// The coffee text.
    case coffee = "buymeacoffee.label.coffee"

    /// Resolves this wording from the package bundle for the supplied locale.
    ///
    /// - Parameter locale: The language and region used to localize the wording.
    /// - Returns: The localized string, supported on iOS 15 and later.
    internal func localizedString(locale: Locale) -> String {
        return String(localized: .init(self.rawValue), bundle: .module, locale: locale)
    }
}

// MARK: - Equatable

extension BuyMeACoffeeText: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeText: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeText: Sendable {}
