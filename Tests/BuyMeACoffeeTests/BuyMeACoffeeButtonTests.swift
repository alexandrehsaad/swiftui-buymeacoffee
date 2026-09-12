// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import Foundation
import Testing

@testable import BuyMeACoffee

@MainActor
@Suite("BuyMeACoffeeButton Tests")
internal struct BuyMeACoffeeButtonTests {
    @Test("Creates a Buy Me a Coffee account URL")
    internal func createsAccountURL() {
        let url: URL = .buyMeACoffee(username: "myusername")

        #expect(url == URL(string: "https://www.buymeacoffee.com/myusername"))
    }

    @Test("Opens the Buy Me a Coffee account URL")
    internal func opensAccountURL() {
        var receivedURL: URL?
        let button = BuyMeACoffeeButton(username: "myusername")

        button.open { url in
            receivedURL = url
            return .handled
        }

        #expect(receivedURL == URL(string: "https://www.buymeacoffee.com/myusername"))
    }

    @Test("Localizes the accessibility label in English")
    internal func localizesAccessibilityLabelInEnglish() {
        let button = BuyMeACoffeeButton(
            username: "myusername",
            label: .coffee
        )
        var accessibilityLabel = button.accessibilityLabel
        accessibilityLabel.locale = Locale(identifier: "en")

        #expect(String(localized: accessibilityLabel) == "Buy me a coffee")
    }

    @Test("Provides an accessibility identifier")
    internal func providesAccessibilityIdentifier() {
        #expect(BuyMeACoffeeButton.Constants.accessibilityIdentifier == "accessibility.buyMeACoffeeButton")
    }
}
