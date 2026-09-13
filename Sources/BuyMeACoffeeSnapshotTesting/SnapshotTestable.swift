import BuyMeACoffee
import SwiftUI
import UIKit

@_exported import SnapshotTesting

/// Provides shared view snapshot assertions for the package's test suites.
///
/// Conforming suites can capture one appearance or both light and dark appearances using
/// an English locale, a display scale of three, and consistent image comparison tolerances.
/// Helpers forward the calling test's source location to preserve reference paths and diagnostics.
@MainActor
package protocol SnapshotTestable {}

extension SnapshotTestable {
    /// Snapshots a view in one appearance using its intrinsic size.
    ///
    /// - Parameters:
    ///   - testName: The test name used for the reference filename.
    ///   - fileID: The calling test's file identifier, used in failure diagnostics.
    ///   - file: The calling test's file path, used to locate snapshot references.
    ///   - line: The source line to report when an assertion fails.
    ///   - column: The source column to report when an assertion fails.
    ///   - accessibilityContrast: The accessibility contrast applied to the snapshot.
    ///   - backgroundColor: The background to capture. Defaults to white in light mode and black in dark mode; use `.clear` for transparency.
    ///   - colorScheme: The light or dark appearance applied to the view.
    ///   - content: The view to snapshot.
    @available(iOS 16.4, *)
    package func assertView<Content>(
        testName: String = #function,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        accessibilityContrast: UIAccessibilityContrast = .normal,
        backgroundColor: Color? = nil,
        colorScheme: ColorScheme,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        let view: some View = content()
            .fixedSize()
            .background(backgroundColor ?? (colorScheme == .light ? .white : .black))
            .environment(\.colorScheme, colorScheme)
            .environment(\.locale, .en)

        let controller = UIHostingController(rootView: view)
        controller.safeAreaRegions = []

        if backgroundColor == .clear {
            controller.view.backgroundColor = .clear
            controller.view.isOpaque = false
        }

        var snapshotStrategy: Snapshotting<UIViewController, UIImage> = .image(
            drawHierarchyInKeyWindow: true,
            precision: 0.99,
            perceptualPrecision: 0.98,
            size: controller.sizeThatFits(in: .zero),
            traits: UITraitCollection(
                traitsFrom: [
                    UITraitCollection(accessibilityContrast: accessibilityContrast),
                    UITraitCollection(displayScale: 3)
                ]
            )
        )
        let imageDiffing: Diffing<UIImage> = snapshotStrategy.diffing
        snapshotStrategy.diffing.diffV2 = { reference, captured in
            // Compare the PNG representation stored by the recorder. Comparing a live extended-range image with a
            // decoded reference produces false CI failures.
            guard let png = captured.pngData() else {
                return ("Could not encode the captured snapshot as PNG.", [])
            }
            return imageDiffing.diffV2(reference, imageDiffing.fromData(png))
        }

        assertSnapshot(
            of: controller,
            as: snapshotStrategy,
            named: colorScheme.description,
            fileID: fileID,
            file: file,
            testName: testName,
            line: line,
            column: column
        )
    }

    /// Asserts light and dark snapshots of the supplied view.
    ///
    /// - Parameters:
    ///   - testName: The test function used to name the snapshots.
    ///   - fileID: The calling test's file identifier, used in failure diagnostics.
    ///   - file: The calling test's file path, used to locate snapshot references.
    ///   - line: The source line to report when an assertion fails.
    ///   - column: The source column to report when an assertion fails.
    ///   - backgroundColor: The background for both appearances; `nil` uses white in light mode and black in dark mode.
    ///   - accessibilityContrast: The accessibility contrast applied to the snapshots.
    ///   - content: A closure that creates the view to snapshot.
    @available(iOS 16.4, *)
    package func assertView<Content>(
        testName: String = #function,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        backgroundColor: Color? = nil,
        accessibilityContrast: UIAccessibilityContrast = .normal,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        self.assertView(
            testName: testName,
            fileID: fileID,
            file: file,
            line: line,
            column: column,
            accessibilityContrast: accessibilityContrast,
            backgroundColor: backgroundColor,
            colorScheme: .light
        ) {
            content()
        }

        self.assertView(
            testName: testName,
            fileID: fileID,
            file: file,
            line: line,
            column: column,
            accessibilityContrast: accessibilityContrast,
            backgroundColor: backgroundColor,
            colorScheme: .dark
        ) {
            content()
        }
    }
}
