// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

/// The border treatment applied by a `BuyMeACoffeeButtonStyle`.
public enum BuyMeACoffeeBorder {
    /// Adds a contrasting border to white buttons in light mode and black buttons in dark mode.
    ///
    /// The border and background use the button border shape inherited from the environment.
    case automatic

    /// Does not add a border.
    case none

    /// The default automatic border treatment.
    public static let `default`: Self = .automatic
}

// MARK: - Equatable

extension BuyMeACoffeeBorder: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeBorder: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeBorder: Sendable {}
