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

@testable import BuyMeACoffee

@Suite(
    "BuyMeACoffeeButton Snapshot Tests",
    .serialized,
    .snapshots(record: ProcessInfo.processInfo.environment["SNAPSHOT_TESTING_RECORD"] == "all" ? .all : .never)
)
@MainActor
internal struct BuyMeACoffeeButtonSnapshotTests {
    @Test("Button control sizes")
    internal func testButtonControlSizes() {
        guard #available(iOS 26, *) else { return }

        assertView {
            Grid {
                ForEach(ControlSize.allCases, id: \.self) { size in
                    GridRow {
                        BuyMeACoffeeButton(username: "")
                            .buttonStyle(.buyMeACoffeeGlass())
                            .controlSize(size)
                    }
                }
            }
        }
    }

    @Test("Button disabled states")
    internal func testButtonDisabledStates() {
        guard #available(iOS 26, *) else { return }
        let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

        assertView {
            Grid {
                ForEach(tints, id: \.self) { tint in
                    GridRow {
                        ForEach([false, true], id: \.self) { isDisabled in
                            BuyMeACoffeeButton(username: "")
                                .buttonStyle(.buyMeACoffeeGlass(tint: tint))
                                .disabled(isDisabled)
                        }
                    }
                }
            }
        }
    }

    @Test("Button dynamic type sizes")
    internal func testButtonDynamicTypeSizes() {
        guard #available(iOS 26, *) else { return }

        assertView {
            Grid {
                ForEach(DynamicTypeSize.allCases, id: \.self) { size in
                    GridRow {
                        BuyMeACoffeeButton(username: "")
                            .buttonStyle(.buyMeACoffeeGlass())
                            .dynamicTypeSize(size)
                    }
                }
            }
        }
    }

    @Test("Button styles across iOS design generations")
    internal func testButtonOSVersions() {
        guard #available(iOS 26, *) else { return }

        func buttonOSVersions(tint: BuyMeACoffeeTint) -> some View {
            Grid {
                GridRow {
                    BuyMeACoffeeButton(username: "")
                        .buttonStyle(.buyMeACoffee(tint: tint, border: .none))
                }
                GridRow {
                    BuyMeACoffeeButton(username: "")
                        .buttonStyle(.buyMeACoffee(tint: tint, border: .automatic))
                }
                GridRow {
                    BuyMeACoffeeButton(username: "")
                        .buttonStyle(.buyMeACoffeeGlass(tint: tint))
                }
            }
        }

        assertView(colorScheme: .light) {
            buttonOSVersions(tint: .white)
        }

        assertView(colorScheme: .dark) {
            buttonOSVersions(tint: .black)
        }
    }

    @Test("Button pressed states")
    internal func testButtonPressedStates() {
        guard #available(iOS 26, *) else { return }
        let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

        assertView {
            Grid {
                ForEach(tints, id: \.self) { tint in
                    GridRow {
                        ForEach([false, true], id: \.self) { isPressed in
                            BuyMeACoffeeButton(username: "")
                                .buttonStyle(.buyMeACoffeeGlass(tint: tint))
                                .environment(\._buyMeACoffeeButtonPressedStateOverride, isPressed)
                        }
                    }
                }
            }
        }
    }

    @Test("Button sizes")
    internal func testButtonSizes() {
        guard #available(iOS 26, *) else { return }

        assertView {
            Grid {
                GridRow {
                    BuyMeACoffeeButton(username: "")
                        .buttonSizing(.fitted)
                }
                GridRow {
                    BuyMeACoffeeButton(username: "")
                        .buttonSizing(.flexible)
                }
            }
            .buttonStyle(.buyMeACoffeeGlass())
            .frame(width: 256)
        }
    }

    @Test("Button styles")
    internal func testButtonStyles() {
        guard #available(iOS 26, *) else { return }

        @ViewBuilder
        func labelCells<Content>(
            @ViewBuilder content: () -> Content
        ) -> some View where Content: View {
            content().labelStyle(.iconOnly)
            content().labelStyle(.titleOnly)
            content().labelStyle(.titleAndIcon)
        }

        assertView {
            Grid {
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.plain) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.borderless) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.bordered) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.borderedProminent) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.buyMeACoffee(border: .default)) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.glass) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.glassProminent) } }
                GridRow { labelCells { BuyMeACoffeeButton(username: "").buttonStyle(.buyMeACoffeeGlass()) } }
            }
        }
    }

    @Test("Button tints")
    internal func testButtonTints() {
        guard #available(iOS 26, *) else { return }

        assertView {
            Grid {
                ForEach(BuyMeACoffeeTint.allCases, id: \.self) { tint in
                    GridRow {
                        BuyMeACoffeeButton(username: "")
                            .buttonStyle(.buyMeACoffeeGlass(tint: tint))
                    }
                }
            }
        }
    }

    @Test("Button tints high contrasts")
    internal func testButtonTintsHighContrasts() {
        guard #available(iOS 26, *) else { return }

        assertView(colorSchemeContrast: .high) {
            Grid {
                ForEach(BuyMeACoffeeTint.allCases, id: \.self) { tint in
                    GridRow {
                        BuyMeACoffeeButton(username: "")
                            .buttonStyle(.buyMeACoffeeGlass(tint: tint))
                    }
                }
            }
        }
    }

    @Test("Button border shapes")
    internal func testButtonBorderShapes() {
        guard #available(iOS 26, *) else { return }

        func wideShapeCells(shape: ButtonBorderShape) -> some View {
            Group {
                BuyMeACoffeeButton(username: "")
                    .labelStyle(.iconOnly)
                BuyMeACoffeeButton(username: "")
                    .labelStyle(.titleOnly)
                BuyMeACoffeeButton(username: "")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.buyMeACoffeeGlass())
            .buttonBorderShape(shape)
        }

        assertView {
            Grid {
                GridRow { wideShapeCells(shape: .roundedRectangle(radius: 0)) }
                GridRow { wideShapeCells(shape: .roundedRectangle(radius: 12)) }
                GridRow { wideShapeCells(shape: .capsule) }
            }
        }
    }
}

extension BuyMeACoffeeButtonSnapshotTests {
    /// Snapshots a view in one appearance using its intrinsic size.
    ///
    /// - Parameters:
    ///   - testName: The test name used for the reference filename.
    ///   - name: The snapshot name appended to the reference filename.
    ///   - colorScheme: The light or dark appearance applied to the view.
    ///   - colorSchemeContrast: The accessibility contrast applied to the snapshot.
    ///   - content: The view to snapshot.
    private func assertView<Content>(
        testName: String = #function,
        colorScheme: ColorScheme,
        colorSchemeContrast: UIAccessibilityContrast = .normal,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        let backgroundColor: Color = colorScheme == .light ? .white : .black
        let view: some View = content()
            .fixedSize()
            .padding()
            .background(backgroundColor)
            .environment(\.colorScheme, colorScheme)
            .environment(\.locale, Locale(identifier: "en_US"))

        assertSnapshot(
            of: view,
            as: .image(
                drawHierarchyInKeyWindow: true,
                precision: 1,
                perceptualPrecision: 0.98,
                layout: .sizeThatFits,
                traits: UITraitCollection(
                    traitsFrom: [
                        UITraitCollection(accessibilityContrast: colorSchemeContrast),
                        UITraitCollection(displayScale: 3)
                    ]
                )
            ),
            named: colorScheme.description,
            testName: testName
        )
    }

    /// Asserts light and dark snapshots of the supplied view.
    ///
    /// - Parameters:
    ///   - testName: The test function used to name the snapshots.
    ///   - colorSchemeContrast: The accessibility contrast applied to the snapshots.
    ///   - content: A closure that creates the view to snapshot.
    private func assertView<Content>(
        testName: String = #function,
        colorSchemeContrast: UIAccessibilityContrast = .normal,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        assertView(
            testName: testName,
            colorScheme: .light,
            colorSchemeContrast: colorSchemeContrast
        ) {
            content()
        }
        assertView(
            testName: testName,
            colorScheme: .dark,
            colorSchemeContrast: colorSchemeContrast
        ) {
            content()
        }
    }
}
