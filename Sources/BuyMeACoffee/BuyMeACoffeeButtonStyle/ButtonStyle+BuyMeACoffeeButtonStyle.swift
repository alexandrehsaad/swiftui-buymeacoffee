// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

@available(iOS 15, *)
extension ButtonStyle
where Self == BuyMeACoffeeButtonStyle {
    /// A `BuyMeACoffeeButtonStyle` with the specified tint, and border treatment.
    ///
    /// - Parameters:
    ///   - tint: The button's color.
    ///   - border: The border treatment applied to the button.
    /// - Returns: A configured `BuyMeACoffeeButtonStyle`.
    @available(iOS 15, *)
    public static func buyMeACoffee(
        tint: BuyMeACoffeeTint = .default,
        border: BuyMeACoffeeBorder = .default
    ) -> Self {
        return .init(
            tint: tint,
            border: border
        )
    }
}
