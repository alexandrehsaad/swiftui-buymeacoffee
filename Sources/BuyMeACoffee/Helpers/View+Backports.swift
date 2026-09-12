// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

extension View {
    /// Expands a flexibly sized button to the available width on iOS 26 and later.
    ///
    /// - Returns: A view that responds to the preferred button sizing behavior when available.
    @ViewBuilder
    internal func backportedButtonSizingFrameMaxWidthInfinity() -> some View {
        if #available(iOS 26, *) {
            self.modifier(ButtonSizingFrameMaxWidthInfinityModifier())
        } else {
            self
        }
    }

    /// Clips the view to the current button border shape on iOS 17 and later.
    ///
    /// - Returns: A view clipped to the button border shape when available.
    @ViewBuilder
    internal func backportedClipShapeButtonBorder() -> some View {
        if #available(iOS 17, *) {
            clipShape(.buttonBorder)
        } else {
            self
        }
    }

    /// Applies flat symbol color rendering on iOS 26 and later.
    ///
    /// - Returns: A view that uses flat symbol color rendering when available.
    @ViewBuilder
    internal func backportedSymbolColorRenderingModeFlat() -> some View {
        if #available(iOS 26, *) {
            symbolColorRenderingMode(.flat)
        } else {
            self
        }
    }
}
