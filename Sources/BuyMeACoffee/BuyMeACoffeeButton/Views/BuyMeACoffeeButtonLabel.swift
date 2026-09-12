// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

/// The visual content displayed by a `BuyMeACoffeeButton`.
@available(iOS 15, *)
internal struct BuyMeACoffeeButtonLabel {
    /// The additional horizontal padding inherited from a Buy Me a Coffee button style.
    @Environment(\.buyMeACoffeeLabelHorizontalPadding)
    private var labelHorizontalPadding: CGFloat

    /// The label displayed by the button.
    private let label: BuyMeACoffeeLabel

    /// Creates the visual content for a button with the specified label.
    ///
    /// - Parameter label: The matched icon and localized wording displayed by the button.
    @available(iOS 15, *)
    internal init(label: BuyMeACoffeeLabel) {
        self.label = label
    }
}

// MARK: - View

@available(iOS 15, *)
extension BuyMeACoffeeButtonLabel: View {
    internal var body: some View {
        Label {
            BuyMeACoffeeTitle(text: self.label.text)
        } icon: {
            BuyMeACoffeeImage(icon: self.label.icon)
        }
        .padding(.horizontal, self.labelHorizontalPadding)
    }
}
