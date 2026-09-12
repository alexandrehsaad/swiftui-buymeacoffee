// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

extension View {
    /// Sets the title appearance for contained `BuyMeACoffeeButton` instances.
    ///
    /// - Parameter font: The appearance used to render the button title.
    /// - Returns: A view that provides the title appearance to contained buttons.
    internal func buyMeACoffeeFont(_ font: BuyMeACoffeeFont) -> some View {
        self.environment(\.buyMeACoffeeFont, font)
    }

    /// Performs an action when a `BuyMeACoffeeButton` requests that its destination be opened.
    ///
    /// Use this modifier to observe opening requests from contained `BuyMeACoffeeButton` instances. The action receives
    /// the button's destination URL and can use it for analytics, logging, or other side effects:
    ///
    /// ```swift
    /// BuyMeACoffeeButton(username: "yourusername")
    ///     .onBuyMeACoffeeButtonOpen { url in
    ///         print("Opening \(url)")
    ///     }
    /// ```
    ///
    /// The action runs before the button requests that the system open its destination. It does not replace or cancel
    /// that request. Other links and buttons do not invoke the action.
    ///
    /// - Parameter action: The action to perform with the destination URL before submitting the system opening request.
    /// - Returns: A view that provides the action to contained `BuyMeACoffeeButton` instances.
    public func onBuyMeACoffeeButtonOpen(
        perform action: @escaping @MainActor (URL) -> Void
    ) -> some View {
        self.environment(\._buyMeACoffeeButtonOpenAction, action)
    }
}
