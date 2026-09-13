// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// A matched icon and localized phrase supported by `BuyMeACoffeeButton`.
public enum BuyMeACoffeeLabel {
    /// The Buy Me a coffee label.
    case coffee

    /// The icon paired with this label.
    internal var icon: BuyMeACoffeeIcon {
        switch self {
        case .coffee:
            return .coffee
        }
    }

    /// The localized wording paired with this label.
    internal var text: BuyMeACoffeeText {
        switch self {
        case .coffee:
            return .coffee
        }
    }

    /// The default `BuyMeACoffeeLabel`.
    public static let `default`: Self = .coffee
}

// MARK: - CaseIterable

extension BuyMeACoffeeLabel: CaseIterable {}

// MARK: - Equatable

extension BuyMeACoffeeLabel: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeLabel: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeLabel: Sendable {}
