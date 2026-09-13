// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// A color from the `BuyMeACoffeeButton` palette.
public enum BuyMeACoffeeTint {
    /// The black color.
    case black

    /// The blue color.
    case blue

    /// The green color.
    case green

    /// The orange color.
    case orange

    /// The purple color.
    case purple

    /// The red color.
    case red

    /// The white color.
    case white

    /// The yellow color.
    case yellow

    /// The primary color applied to the icon.
    internal var iconPrimaryColor: Color {
        switch self {
        case .black:
            return .white
        default:
            return .black
        }
    }

    /// The secondary color applied to the icon.
    internal var iconSecondaryColor: Color {
        switch self {
        case .yellow:
            return .white
        default:
            return .buymeacoffeeYellow
        }
    }

    /// The color applied to the text or logo title.
    internal var textColor: Color {
        switch self {
        case .white, .yellow:
            return .black
        default:
            return .white
        }
    }

    /// The SwiftUI color represented by this palette value.
    internal var backgroundColor: Color {
        switch self {
        case .black:
            return .black
        case .blue:
            return .buymeacoffeeBlue
        case .green:
            return .buymeacoffeeGreen
        case .orange:
            return .buymeacoffeeOrange
        case .purple:
            return .buymeacoffeePurple
        case .red:
            return .buymeacoffeeRed
        case .white:
            return .white
        case .yellow:
            return .buymeacoffeeYellow
        }
    }

    /// Returns the appropriate border color for a button tint and appearance.
    ///
    /// - Parameters:
    ///   - border: The border treatment applied to the button.
    ///   - colorScheme: The current light or dark appearance.
    /// - Returns: A contrasting color when a border is needed, or `nil` otherwise.
    internal func borderColor(
        border: BuyMeACoffeeBorder,
        colorScheme: ColorScheme
    ) -> Color? {
        guard border == .automatic else {
            return nil
        }

        return self.borderColor(colorScheme: colorScheme)
    }

    /// Returns the border color appropriate for this tint and appearance.
    ///
    /// - Parameter colorScheme: The current light or dark appearance.
    /// - Returns: A contrasting color for black or white when needed, or `nil` otherwise.
    public func borderColor(
        colorScheme: ColorScheme
    ) -> Color? {
        switch (self, colorScheme) {
        case (.white, .light):
            return .black
        case (.black, .dark):
            return .white
        default:
            return nil
        }
    }

    /// The default yellow tint.
    public static var `default`: Self {
        return .yellow
    }
}

// MARK: - CaseIterable

extension BuyMeACoffeeTint: CaseIterable {}

// MARK: - Equatable

extension BuyMeACoffeeTint: Equatable {}

// MARK: - Hashable

extension BuyMeACoffeeTint: Hashable {}

// MARK: - Sendable

extension BuyMeACoffeeTint: Sendable {}
