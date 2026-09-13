// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

@available(iOS 26, *)
extension ButtonStyle
where Self == BuyMeACoffeeGlassButtonStyle {
    /// A `BuyMeACoffeeGlassButtonStyle` with the specified tint.
    ///
    /// - Parameter tint: The tint applied to the glass.
    /// - Returns: A configured `BuyMeACoffeeGlassButtonStyle`.
    @available(iOS 26, *)
    public static func buyMeACoffeeGlass(tint: BuyMeACoffeeTint = .default) -> Self {
        return .init(tint: tint)
    }
}
