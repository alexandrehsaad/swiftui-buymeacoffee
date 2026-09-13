// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

extension ControlSize {
    /// The horizontal and vertical padding for the current control size.
    internal var padding: (horizontal: CGFloat, vertical: CGFloat) {
        switch self {
        case .mini:
            return (10, 5)
        case .small:
            return (10, 5)
        case .regular:
            return (12, 7)
        case .large:
            return (20, 15)
        case .extraLarge:
            return (20, 15)
        @unknown default:
            return (12, 7)
        }
    }
}
