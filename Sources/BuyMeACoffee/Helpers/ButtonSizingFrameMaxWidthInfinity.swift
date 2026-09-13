// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// A modifier that expands a button configured for flexible sizing to the available width.
@available(iOS 26, *)
internal struct ButtonSizingFrameMaxWidthInfinityModifier {
    /// The preferred sizing behavior of the button.
    @Environment(\.buttonSizing)
    private var buttonSizing: ButtonSizing

    /// Creates a button sizing frame modifier.
    @available(iOS 26, *)
    internal init() {}

    /// The maximum width for the preferred button sizing behavior.
    private var maxWidth: CGFloat? {
        self.buttonSizing == .flexible ? .infinity : nil
    }
}

// MARK: - ViewModifier

@available(iOS 26, *)
extension ButtonSizingFrameMaxWidthInfinityModifier: ViewModifier {
    internal func body(content: Content) -> some View {
        content.frame(maxWidth: self.maxWidth)
    }
}
