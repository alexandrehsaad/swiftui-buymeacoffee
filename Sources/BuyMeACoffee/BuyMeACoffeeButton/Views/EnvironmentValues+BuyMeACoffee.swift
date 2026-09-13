// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

extension EnvironmentValues {
    /// The appearance used to render a `BuyMeACoffeeButton` title.
    @Entry
    internal var buyMeACoffeeFont: BuyMeACoffeeFont = .default

    /// The horizontal offset applied to a `BuyMeACoffeeButton` image.
    @Entry
    internal var buyMeACoffeeImageOffset: CGFloat = 1

    /// The additional horizontal padding applied to a Buy Me a Coffee button label.
    @Entry
    internal var buyMeACoffeeLabelHorizontalPadding: CGFloat = 0

    /// The optional palette used to render a styled `BuyMeACoffeeButton`.
    @Entry
    internal var buyMeACoffeeTint: BuyMeACoffeeTint? = nil

    /// The horizontal scale applied to a Buy Me a Coffee logo title.
    @Entry
    internal var buyMeACoffeeTitleScale: CGFloat = 1

    /// The action notified when a `BuyMeACoffeeButton` requests that the system open its destination URL.
    ///
    /// This entry is the internal backing value for `View/onBuyMeACoffeeButtonOpen(perform:)`. Its leading
    /// underscore distinguishes the implementation detail from environment values intended for direct use by views.
    @Entry
    internal var _buyMeACoffeeButtonOpenAction: @MainActor (URL) -> Void = { _ in }

    /// The optional pressed state used to produce deterministic `BuyMeACoffeeButton` snapshots.
    ///
    /// This testing hook takes precedence over the live button configuration when it contains a value. Its leading
    /// underscore discourages use by production code.
    @Entry
    internal var _buyMeACoffeeButtonPressedStateOverride: Bool? = nil
}
