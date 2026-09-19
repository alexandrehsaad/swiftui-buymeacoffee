// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// The appearance for a `BuyMeACoffeeButton`.
@available(iOS 15, *)
public struct BuyMeACoffeeButtonStyle {
    /// Whether the system preference to reduce motion is enabled.
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion: Bool

    /// The current light or dark appearance.
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

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

    /// The button's border treatment.
    private let border: BuyMeACoffeeBorder

    /// Creates a new instance with the specified tint, and border treatment.
    ///
    /// - Parameters:
    ///   - tint: The button's tint.
    ///   - border: The border treatment applied to the button.
    @available(iOS 15, *)
    public init(
        tint: BuyMeACoffeeTint = .default,
        border: BuyMeACoffeeBorder = .automatic
    ) {
        self.tint = tint
        self.border = border
    }

    /// The background displayed for the current enabled state.
    @ViewBuilder
    private var backgroundColor: some View {
        self.isEnabled ? self.tint.backgroundColor : Color.secondary.opacity(0.25)
    }

    /// The border displayed for the current border treatment and color scheme.
    @ViewBuilder
    private var borderColor: some View {
        if #available(iOS 17, *) {
            if let borderColor: Color = self.tint.borderColor(
                border: self.border,
                colorScheme: self.colorScheme
            ) {
                ButtonBorderShape.buttonBorder
                    .strokeBorder(borderColor, lineWidth: 1)
            }
        }
    }
}

// MARK: - ButtonStyle

@available(iOS 15, *)
extension BuyMeACoffeeButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        let isPressed: Bool = self.pressedStateOverride ?? configuration.isPressed

        return configuration.label
            .environment(\.buyMeACoffeeImageOffset, self.dynamicTypeSize.imageOffset)
            .environment(\.buyMeACoffeeLabelHorizontalPadding, self.dynamicTypeSize.labelHorizontalPadding)
            .environment(\.buyMeACoffeeTint, self.tint)
            .environment(\.buyMeACoffeeTitleScale, self.dynamicTypeSize.titleScale)
            .symbolRenderingMode(.palette)
            .backportedSymbolColorRenderingModeFlat()
            .padding(.horizontal, self.controlSize.padding.horizontal)
            .padding(.vertical, self.controlSize.padding.vertical)
            .backportedButtonSizingFrameMaxWidthInfinity()
            .background {
                self.backgroundColor
                self.borderColor
            }
            .backportedClipShapeButtonBorder()
            .opacity(isPressed ? 0.75 : 1)
            .animation(
                self.accessibilityReduceMotion ? nil : Animation.default.speed(2),
                value: isPressed
            )
            .allowsHitTesting(self.isEnabled)
    }
}
