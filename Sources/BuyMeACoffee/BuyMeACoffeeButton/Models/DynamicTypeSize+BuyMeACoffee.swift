// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

/// Dynamic Type adjustments applied to the contents of a `BuyMeACoffeeButton`.
extension DynamicTypeSize {
    /// The horizontal offset applied to the image for the current Dynamic Type size.
    internal var imageOffset: CGFloat {
        switch self {
        case .accessibility4:
            return 9
        case .accessibility5:
            return 10.5
        default:
            return 1
        }
    }

    /// The scale applied to the logo title for the current Dynamic Type size.
    internal var titleScale: CGFloat {
        switch self {
        case .accessibility4:
            return 0.945
        case .accessibility5:
            return 0.93
        default:
            return 1
        }
    }

    /// The horizonytal padding applied to the button label for the current Dynamic Type size.
    internal var labelHorizontalPadding: CGFloat {
        switch self {
        case .accessibility1:
            return 2
        case .accessibility2:
            return 4
        case .accessibility3:
            return 6
        default:
            return 0
        }
    }
}
