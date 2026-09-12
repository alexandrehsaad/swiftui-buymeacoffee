// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

extension ColorScheme: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "unknown"
        }
    }
}
