// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

/// A Liquid Glass appearance for a `BuyMeACoffeeButton`.
@available(iOS 26, *)
public struct BuyMeACoffeeGlassButtonStyle {
    /// Whether the system preference to reduce motion is enabled.
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion: Bool

    /// The preferred sizing behavior of the button.
    @Environment(\.buttonSizing)
    private var buttonSizing: ButtonSizing

    /// The size applied to the button.
    @Environment(\.controlSize)
    private var controlSize: ControlSize

    /// The current Dynamic Type size used to adjust the button's label.
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize: DynamicTypeSize

    /// Whether the button is enabled for user interaction.
    @Environment(\.isEnabled)
    private var isEnabled: Bool

    /// The optional pressed-state override for internal testing.
    @Environment(\._buyMeACoffeeButtonPressedStateOverride)
    private var pressedStateOverride: Bool?

    /// The button's tint.
    private let tint: BuyMeACoffeeTint

    /// Creates a Liquid Glass style with the specified tint.
    ///
    /// - Parameter tint: The tint applied to the glass.
    @available(iOS 26, *)
    public init(tint: BuyMeACoffeeTint = .default) {
        self.tint = tint
    }
}

// MARK: - ButtonStyle

@available(iOS 26, *)
extension BuyMeACoffeeGlassButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        let isPressed: Bool = self.pressedStateOverride ?? configuration.isPressed

        return configuration.label
            .environment(\.buyMeACoffeeImageOffset, self.dynamicTypeSize.imageOffset)
            .environment(\.buyMeACoffeeLabelHorizontalPadding, self.dynamicTypeSize.labelHorizontalPadding)
            .environment(\.buyMeACoffeeTint, self.tint)
            .environment(\.buyMeACoffeeTitleScale, self.dynamicTypeSize.titleScale)
            .symbolRenderingMode(.palette)
            .symbolColorRenderingMode(.flat)
            .padding(.horizontal, self.controlSize.padding.horizontal)
            .padding(.vertical, self.controlSize.padding.vertical)
            .frame(maxWidth: self.buttonSizing == .flexible ? .infinity : nil)
            .opacity(isPressed ? 0.75 : 1)
            .glassEffect(
                .regular
                    .tint(self.isEnabled ? self.tint.backgroundColor : Color.primary.opacity(0.08))
                    .interactive(),
                in: .buttonBorder
            )
            .animation(
                self.accessibilityReduceMotion ? nil : Animation.default,
                value: isPressed
            )
            .allowsHitTesting(self.isEnabled)
    }
}
