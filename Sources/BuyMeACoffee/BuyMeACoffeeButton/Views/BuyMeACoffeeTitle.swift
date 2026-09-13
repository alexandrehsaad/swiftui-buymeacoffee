// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// The title displayed by a `BuyMeACoffeeButton`.
@available(iOS 15, *)
internal struct BuyMeACoffeeTitle {
    /// The title appearance inherited from `BuyMeACoffeeButtonStyle`.
    @Environment(\.buyMeACoffeeFont)
    private var font: BuyMeACoffeeFont

    /// Whether the title is enabled for user interaction.
    @Environment(\.isEnabled)
    private var isEnabled: Bool

    /// The optional palette inherited from `BuyMeACoffeeButtonStyle`.
    @Environment(\.buyMeACoffeeTint)
    private var tint: BuyMeACoffeeTint?

    /// The horizontal scale inherited from a Buy Me a Coffee button style.
    @Environment(\.buyMeACoffeeTitleScale)
    private var titleScale: CGFloat

    /// A multiplier that scales the optical adjustment relative to the title text style.
    @ScaledMetric(relativeTo: .title3)
    private var scale: CGFloat = 1

    /// The localized wording represented by the title.
    private let text: BuyMeACoffeeText

    /// Creates a title with the specified localized wording.
    ///
    /// - Parameter text: The localized wording represented by the title.
    @available(iOS 15, *)
    internal init(text: BuyMeACoffeeText) {
        self.text = text
    }

    /// The height of the logo, scaled relative to the title text style.
    private var logoHeight: CGFloat {
        return 24 * self.scale
    }

    /// The scaled vertical adjustment for the current title appearance.
    private var verticalOffset: CGFloat {
        return self.font.verticalOffset * self.scale
    }
}

// MARK: - View

@available(iOS 15, *)
extension BuyMeACoffeeTitle: View {
    internal var body: some View {
        Image("buymeacoffee-logo", bundle: .module)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .imageScale(.medium)
            .frame(height: self.logoHeight)
            .scaleEffect(
                x: self.titleScale,
                y: self.titleScale,
                anchor: .center
            )
            .offset(y: self.verticalOffset)
            .ifLet(self.tint) { view, tint in
                if self.isEnabled {
                    view.foregroundStyle(tint.textColor)
                } else {
                    view.foregroundStyle(.tertiary)
                }
            }
    }
}
