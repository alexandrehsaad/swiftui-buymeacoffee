// This source file is part of the BuyMeACoffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of BuyMeACoffee project authors

import SwiftUI

/// A SwiftUI link that navigates to a Buy Me a Coffee account.
///
/// `BuyMeACoffeeButton` provides a branded link that people can use to support your work.
///
/// - Important: Tapping the button only opens your Buy Me a Coffee page in the default browser. It does not initiate a
/// transaction. For more details about accepting donations, visit the [Buy Me a Coffee](https://buymeacoffee.com)
/// website.
@MainActor
@available(iOS 15, *)
public struct BuyMeACoffeeButton {
    /// Constants used to configure the button's system integrations.
    internal enum Constants {
        /// The stable identifier exposed to accessibility and UI automation systems.
        internal static let accessibilityIdentifier: String = "accessibility.buyMeACoffeeButton"
    }

    /// The observational action performed with the destination URL before requesting that the system open it.
    @Environment(\._buyMeACoffeeButtonOpenAction)
    private var openAction

    /// The locale used to resolve the button’s accessible wording.
    @Environment(\.locale)
    private var locale: Locale

    /// A multiplier that scales the icon width relative to the title text style.
    @ScaledMetric(relativeTo: .title3)
    private var scale: CGFloat = 1

    /// The creator's Buy Me a Coffee page URL.
    private let url: URL

    /// The localized wording shown beside the icon.
    private let label: BuyMeACoffeeLabel

    /// The localized wording exposed as the accessibility label.
    private var accessibilityLabel: String {
        return self.label.text.localizedString(locale: self.locale)
    }

    /// Creates a new instance with the specified username.
    ///
    /// - Parameters:
    ///   - username: The account name appended to the Buy Me a Coffee URL.
    ///   - label: The matched icon and localized wording shown by the button. The default value is `.default`.
    @available(iOS 15, *)
    public init(
        username: String,
        label: BuyMeACoffeeLabel = .default
    ) {
        self.url = .buyMeACoffee(username: username)
        self.label = label
    }

    /// Opens the button's destination using the specified action.
    ///
    /// - Parameter action: The action used to handle the destination.
    /// - Returns: The result of handling the destination.
    @discardableResult
    internal func open(perform action: (URL) -> OpenURLAction.Result) -> OpenURLAction.Result {
        return action(self.url)
    }
}

// MARK: - View

@available(iOS 15, *)
extension BuyMeACoffeeButton: View {
    public var body: some View {
        Link(destination: self.url) {
            BuyMeACoffeeButtonLabel(label: self.label)
        }
        .environment(
            \.openURL,
            OpenURLAction { _ in
                self.open { url in
                    self.openAction(url)
                    return .systemAction(url)
                }
            }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: self.accessibilityLabel))
        .accessibilityIdentifier(Self.Constants.accessibilityIdentifier)
    }
}
