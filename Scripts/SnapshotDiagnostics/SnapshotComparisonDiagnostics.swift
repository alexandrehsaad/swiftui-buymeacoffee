import Foundation
import MetalPerformanceShaders
import SnapshotTesting
import Testing
import UIKit
import SwiftUI
import BuyMeACoffee

/// Diagnoses fixed images and live captures without recording references.
@Suite(.serialized)
@MainActor
struct SnapshotComparisonDiagnostics {
    @Test
    func compareLiveBorderShapes() async throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let references = root.appendingPathComponent("Tests/BuyMeACoffeeSnapshotTests/__Snapshots__/BuyMeACoffeeButtonSnapshotTests")

        func cells(_ shape: ButtonBorderShape) -> some View {
            Group {
                BuyMeACoffeeButton(username: "").labelStyle(.iconOnly)
                BuyMeACoffeeButton(username: "").labelStyle(.titleOnly)
                BuyMeACoffeeButton(username: "").labelStyle(.titleAndIcon)
            }
            .buttonStyle(.buyMeACoffeeGlass())
            .buttonBorderShape(shape)
        }

        for (appearance, scheme) in [("light", ColorScheme.light), ("dark", ColorScheme.dark)] {
            let view = Grid {
                GridRow { cells(.roundedRectangle(radius: 0)) }
                GridRow { cells(.roundedRectangle(radius: 12)) }
                GridRow { cells(.capsule) }
            }
            .padding()
            .fixedSize()
            .background(scheme == .light ? Color.white : Color.black)
            .environment(\.colorScheme, scheme)
            .environment(\.locale, Locale(identifier: "en"))
            let controller = UIHostingController(rootView: view)
            controller.safeAreaRegions = []
            let strategy = Snapshotting<UIViewController, UIImage>.image(
                drawHierarchyInKeyWindow: true,
                precision: 0.98,
                perceptualPrecision: 0.98,
                size: controller.sizeThatFits(in: .zero),
                traits: UITraitCollection(traitsFrom: [
                    UITraitCollection(accessibilityContrast: .normal),
                    UITraitCollection(displayScale: 3)
                ])
            )
            let captured: UIImage = await withCheckedContinuation { continuation in
                strategy.snapshot(controller).run { continuation.resume(returning: $0) }
            }
            let png = try #require(captured.pngData())
            let reloaded = strategy.diffing.fromData(png)
            let reference = strategy.diffing.fromData(try Data(contentsOf:
                references.appendingPathComponent("testButtonBorderShapes.\(appearance).png")))
            for (name, image) in [("reference", reference), ("live", captured), ("reloaded", reloaded)] {
                let cg = try #require(image.cgImage)
                print("DIAGNOSTIC \(appearance) \(name): \(cg.width)x\(cg.height), scale \(image.scale), bpc \(cg.bitsPerComponent), bpp \(cg.bitsPerPixel), rowBytes \(cg.bytesPerRow), bitmap \(cg.bitmapInfo.rawValue), colorSpace \(String(describing: cg.colorSpace))")
            }
            let direct = strategy.diffing.diffV2(reference, captured)
            let roundTrip = strategy.diffing.diffV2(reference, reloaded)
            let identity = strategy.diffing.diffV2(captured, captured)
            print("DIAGNOSTIC \(appearance) direct: \(direct?.0 ?? "PASS")")
            print("DIAGNOSTIC \(appearance) PNG round-trip: \(roundTrip?.0 ?? "PASS")")
            print("DIAGNOSTIC \(appearance) live identity: \(identity?.0 ?? "PASS")")
            #expect(identity == nil)
            // Keep the known CI failure visible without failing the workaround check.
            #expect(roundTrip == nil)
        }
    }

    @Test
    func compareCIAttachments() throws {
        // This file is copied into Tests/BuyMeACoffeeSnapshotTests for diagnostic runs.
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let fixtures = root.appendingPathComponent("Scripts/SnapshotDiagnostics/Fixtures")
        let strategy = Diffing<UIImage>.image(precision: 0.98, perceptualPrecision: 0.98, scale: 3)
        let reference = strategy.fromData(try Data(contentsOf: fixtures.appendingPathComponent("reference.png")))
        let failure = strategy.fromData(try Data(contentsOf: fixtures.appendingPathComponent("failure.png")))
        let device = MTLCreateSystemDefaultDevice()
        print("DIAGNOSTIC OS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
        print("DIAGNOSTIC Metal: \(device?.name ?? "unavailable")")
        print("DIAGNOSTIC MPS supported: \(device.map { MPSSupportsMTLDevice($0) } ?? false)")
        for (name, image) in [("reference", reference), ("failure", failure)] {
            let cg = try #require(image.cgImage)
            print("DIAGNOSTIC \(name): \(cg.width)x\(cg.height), scale \(image.scale), bits/component \(cg.bitsPerComponent), bits/pixel \(cg.bitsPerPixel), rowBytes \(cg.bytesPerRow)")
        }
        let control = strategy.diffV2(reference, reference)
        print("DIAGNOSTIC identity: \(control?.0 ?? "PASS")")
        #expect(control == nil)
        let result = strategy.diffV2(reference, failure)
        print("DIAGNOSTIC reference vs failure: \(result?.0 ?? "PASS")")
        #expect(result == nil)
    }
}
