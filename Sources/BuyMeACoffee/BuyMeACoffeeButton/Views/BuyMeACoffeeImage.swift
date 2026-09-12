// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

/// The image displayed by a `BuyMeACoffeeButton`.
@available(iOS 15, *)
internal struct BuyMeACoffeeImage {
    /// The horizontal offset inherited from a Buy Me a Coffee button style.
    @Environment(\.buyMeACoffeeImageOffset)
    private var imageOffset: CGFloat

    /// Whether the image is enabled for user interaction.
    @Environment(\.isEnabled)
    private var isEnabled: Bool

    /// The optional palette inherited from `BuyMeACoffeeButtonStyle`.
    @Environment(\.buyMeACoffeeTint)
    private var tint: BuyMeACoffeeTint?

    /// A multiplier that scales the optical adjustment relative to the title text style.
    @ScaledMetric(relativeTo: .title3)
    private var scale: CGFloat = 1

    /// The icon represented by this image.
    private let icon: BuyMeACoffeeIcon

    /// Creates an image with the specified icon.
    ///
    /// - Parameter icon: The icon represented by the image.
    @available(iOS 15, *)
    internal init(icon: BuyMeACoffeeIcon) {
        self.icon = icon
    }

    /// The width of the icon, scaled relative to the title text style.
    private var imageWidth: CGFloat {
        return 24 * self.scale
    }
}

// MARK: - View

@available(iOS 15, *)
extension BuyMeACoffeeImage: View {
    internal var body: some View {
        Image(self.icon.filename, bundle: .module)
            .resizable()
            .scaledToFit()
            .imageScale(.medium)
            .frame(width: self.imageWidth)
            .offset(x: self.imageOffset)
            .ifLet(self.tint) { view, tint in
                if self.isEnabled {
                    view.foregroundStyle(
                        tint.iconPrimaryColor,
                        tint.iconSecondaryColor
                    )
                } else {
                    view.foregroundStyle(.tertiary)
                }
            }
    }
}
