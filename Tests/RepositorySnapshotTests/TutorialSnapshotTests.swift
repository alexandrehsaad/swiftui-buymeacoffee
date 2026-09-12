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
    "Tutorial Snapshot Tests",
    .serialized,
    .snapshots(record: ProcessInfo.processInfo.environment["SNAPSHOT_TESTING_RECORD"] == "all" ? .all : .never)
)
@MainActor
internal struct TutorialSnapshotTests: SnapshotTestable {
    @Test("Make tutorial chapter 1 banner")
    internal func makeTutorialChapter1Banner() {
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
                }
                GridRow {
                    button(tint: .black)
                    button(tint: .blue)
                    button(tint: .orange)
                }
                GridRow {
                    button(tint: .yellow)
                    button(tint: .red)
                    button(tint: .white)
                }
                GridRow {
                    button(tint: .orange)
                    button(tint: .purple)
                    button(tint: .green)
                }
                GridRow {
                    button(tint: .white)
                    button(tint: .blue)
                    button(tint: .red)
                }
            }
            .padding()
            .padding()
        }
    }

    @Test("Make tutorial chapter 1 section 1 step 4 screenshot")
    internal func makeTutorialChapter1Section1Step4Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            BuyMeACoffeeButton(username: "yourusername")
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 1 screenshot")
    internal func makeTutorialChapter1Section2Step1Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.plain)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 2 screenshot")
    internal func makeTutorialChapter1Section2Step2Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.plain)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.borderless)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 3 screenshot")
    internal func makeTutorialChapter1Section2Step3Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.plain)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.borderless)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.bordered)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 4 screenshot")
    internal func makeTutorialChapter1Section2Step4Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.plain)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.borderless)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.bordered)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 5 screenshot")
    internal func makeTutorialChapter1Section2Step5Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glass)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 6 screenshot")
    internal func makeTutorialChapter1Section2Step6Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glass)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glassProminent)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 7 screenshot")
    internal func makeTutorialChapter1Section2Step7Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glass)
                    .foregroundStyle(.black, .yellow)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glassProminent)
                    .foregroundStyle(.black, .white)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 8 screenshot")
    internal func makeTutorialChapter1Section2Step8Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glass)
                    .foregroundStyle(.black, .yellow)

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.glassProminent)
                    .foregroundStyle(.black, .white)
                    .tint(.yellow)
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 9 screenshot")
    internal func makeTutorialChapter1Section2Step9Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.buyMeACoffee())
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 10 screenshot")
    internal func makeTutorialChapter1Section2Step10Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonStyle(.buyMeACoffee())
                    .tint(.red) // No-op
                    .foregroundStyle(.red, .red) // No-op
                    .symbolRenderingMode(.hierarchical) // No-op
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 11 screenshot")
    internal func makeTutorialChapter1Section2Step11Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .buttonBorderShape(.roundedRectangle(radius: 6))

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonBorderShape(.roundedRectangle(radius: 18))

                BuyMeACoffeeButton(username: "yourusername")
                    .buttonBorderShape(.capsule)
            }
            .buttonStyle(.buyMeACoffee())
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 12 screenshot")
    internal func makeTutorialChapter1Section2Step12Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                BuyMeACoffeeButton(username: "yourusername")
                    .labelStyle(.iconOnly)

                BuyMeACoffeeButton(username: "yourusername")
                    .labelStyle(.titleOnly)

                BuyMeACoffeeButton(username: "yourusername")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.buyMeACoffee())
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 13 screenshot")
    internal func makeTutorialChapter1Section2Step13Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                ForEach(ControlSize.allCases, id: \.self) { size in
                    BuyMeACoffeeButton(username: "yourusername")
                        .buttonStyle(.buyMeACoffee())
                        .controlSize(size)
                }
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 14 screenshot")
    internal func makeTutorialChapter1Section2Step14Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                ForEach([ButtonSizing.fitted, .flexible], id: \.self) { size in
                    BuyMeACoffeeButton(username: "yourusername")
                        .buttonStyle(.buyMeACoffee())
                        .buttonSizing(size)
                }
            }
            .frame(width: 256)
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 15 screenshot")
    internal func makeTutorialChapter1Section2Step15Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                ForEach(DynamicTypeSize.allCases, id: \.self) { size in
                    BuyMeACoffeeButton(username: "yourusername")
                        .buttonStyle(.buyMeACoffee())
                        .dynamicTypeSize(size)
                }
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 16 screenshot")
    internal func makeTutorialChapter1Section2Step16Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                ForEach(BuyMeACoffeeTint.allCases, id: \.self) { tint in
                    BuyMeACoffeeButton(username: "yourusername")
                        .buttonStyle(.buyMeACoffee(tint: tint))
                }
            }
        }
    }

    @Test("Make tutorial chapter 1 section 2 step 17 screenshot")
    internal func makeTutorialChapter1Section2Step17Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            VStack {
                ForEach(BuyMeACoffeeTint.allCases, id: \.self) { tint in
                    BuyMeACoffeeButton(username: "yourusername")
                        .buttonStyle(.buyMeACoffeeGlass(tint: tint))
                }
            }
        }
    }

    @Test("Make tutorial chapter 1 section 3 step 1 screenshot")
    internal func makeTutorialChapter1Section3Step1Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

            VStack {
                ForEach(tints, id: \.self) { tint in
                    BuyMeACoffeeButton(username: "")
                        .buttonStyle(.buyMeACoffee(tint: tint, border: .automatic))
                }
            }
        }
    }

    @Test("Make tutorial chapter 1 section 3 step 2 screenshot")
    internal func makeTutorialChapter1Section3Step2Screenshot() {
        guard #available(iOS 26, *) else { return }

        assertScreenshot {
            @Environment(\.colorScheme) var colorScheme
            let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

            VStack {
                ForEach(tints, id: \.self) { tint in
                    BuyMeACoffeeButton(username: "")
                        .buttonStyle(.buyMeACoffee(tint: tint))
                        .overlay {
                            if let borderColor = tint.borderColor(colorScheme: colorScheme) {
                                Capsule()
                                    .stroke(borderColor, lineWidth: 1)
                            }
                        }
                        .clipShape(.capsule)
                }
            }
        }
    }
}

extension TutorialSnapshotTests {
    /// Asserts a light-mode screenshot of the supplied view at the tutorial canvas size.
    ///
    /// - Parameters:
    ///   - testName: The test function used to name the screenshot.
    ///   - content: A closure that creates the view to capture.
    @available(iOS 16.4, *)
    private func assertScreenshot<Content>(
        testName: String = #function,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column,
        @ViewBuilder content: () -> Content
    ) where Content: View {
        assertView(
            testName: testName,
            fileID: fileID,
            file: file,
            line: line,
            column: column,
            colorScheme: .light
        ) {
            content()
                .frame(width: 375, height: 812)
        }
    }
}
