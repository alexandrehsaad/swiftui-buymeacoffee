import Foundation
import MetalPerformanceShaders
import SnapshotTesting
import Testing
import UIKit

/// Compares fixed CI attachments without rendering views or recording references.
@Suite(.serialized)
@MainActor
struct SnapshotComparisonDiagnostics {
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
