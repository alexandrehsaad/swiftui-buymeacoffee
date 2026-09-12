// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import Foundation
import SnapshotTesting
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
internal struct RepositorySnapshotTests {
    @Test("Make ReadMe banner")
    internal func makeReadMeBanner() {
        guard #available(iOS 26, *) else { return }

        func button(tint: BuyMeACoffeeTint) -> some View {
            BuyMeACoffeeButton(username: "")
                .buttonStyle(.buyMeACoffeeGlass(tint: tint))
        }

        assertBanner {
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
            .fixedSize()
            .padding()
            .frame(width: 1_280, height: 680)
            .background(.white)
            .environment(\.colorScheme, .light)
        }
    }

    @Test("Make ReadMe button")
    internal func makeBuyMeACoffeeButton() {
        guard #available(iOS 26, *) else { return }

        assertBanner {
            BuyMeACoffeeButton(username: "")
                .buttonStyle(.buyMeACoffeeGlass(tint: .yellow))
                .fixedSize()
        }
    }
}

extension RepositorySnapshotTests {
    /// Asserts a transparent snapshot of the supplied view at its fitted size.
    ///
    /// - Parameters:
    ///   - testName: The test function used to name the snapshot.
    ///   - content: A closure that creates the view to snapshot.
    private func assertBanner<Content>(
        testName: String = #function,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        let controller = UIHostingController(rootView: content())
        controller.safeAreaRegions = []
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false

        assertSnapshot(
            of: controller,
            as: .image(
                drawHierarchyInKeyWindow: true,
                precision: 1,
                perceptualPrecision: 0.98,
                size: controller.sizeThatFits(in: .zero),
                traits: .init(displayScale: 3)
            ),
            testName: testName
        )
    }
}
