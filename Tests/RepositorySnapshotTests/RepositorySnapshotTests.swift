// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import BuyMeACoffeeSnapshotTesting
import Foundation
import SwiftUI
import Testing
import UIKit

@testable import BuyMeACoffee

@Suite(
    "Repository Snapshot Tests",
    .serialized,
    .snapshots(record: ProcessInfo.processInfo.environment["SNAPSHOT_TESTING_RECORD"] == "all" ? .all : .never)
)
@MainActor
internal struct RepositorySnapshotTests: SnapshotTestable {
    @Test("Make ReadMe banner")
    internal func makeReadMeBanner() {
        guard #available(iOS 26, *) else { return }

        func button(tint: BuyMeACoffeeTint) -> some View {
            BuyMeACoffeeButton(username: "")
                .buttonStyle(.buyMeACoffeeGlass(tint: tint))
        }

        assertView(colorScheme: .light) {
            Grid {
                GridRow {
                    button(tint: .purple)
                    button(tint: .white)
                    button(tint: .green)
                    button(tint: .yellow)
                    button(tint: .red)
                }
                GridRow {
                    button(tint: .black)
                    button(tint: .blue)
                    button(tint: .orange)
                    button(tint: .purple)
                    button(tint: .green)
                }
                GridRow {
                    button(tint: .yellow)
                    button(tint: .red)
                    button(tint: .white)
                    button(tint: .blue)
                    button(tint: .black)
                }
                GridRow {
                    button(tint: .orange)
                    button(tint: .purple)
                    button(tint: .green)
                    button(tint: .black)
                    button(tint: .yellow)
                }
                GridRow {
                    button(tint: .white)
                    button(tint: .blue)
                    button(tint: .red)
                    button(tint: .orange)
                    button(tint: .green)
                }
                GridRow {
                    button(tint: .black)
                    button(tint: .yellow)
                    button(tint: .purple)
                    button(tint: .white)
                    button(tint: .red)
                }
                GridRow {
                    button(tint: .blue)
                    button(tint: .orange)
                    button(tint: .green)
                    button(tint: .red)
                    button(tint: .white)
                }
            }
            .padding()
            .frame(width: 1_280, height: 680)
        }
    }

    @Test("Make ReadMe button")
    internal func makeReadMeButton() {
        guard #available(iOS 26, *) else { return }

        assertView(backgroundColor: .clear, colorScheme: .light) {
            BuyMeACoffeeButton(username: "")
                .buttonStyle(.buyMeACoffeeGlass(tint: .yellow))
        }
    }
}
