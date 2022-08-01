// BuyMeACoffeeButton.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

/// A SwiftUI link that navigates to a Buy Me a Coffee account.
///
/// BuyMeACoffeeButton simplifies accepting donations. Add this button to your SwiftUI user interface in situations when users may want to make a donation for supporting your free app.
///
/// - important: When a user taps the button, it only opens your Buy Me a Coffee page on their default browser — it does not initiate a transaction. For more details about accepting donations, visit the [Buy Me a Coffee](https://buymeacoffee.com) website.
public struct BuyMeACoffeeButton {
	///
	internal let username: String
	
	///
	internal let text: BuyMeACoffeeText
	
	/// Creates a new instance with the specified username.
	///
	/// - parameter username:
	public init(
		username: String,
		text: BuyMeACoffeeText = .coffee
	) {
		Font.registerFont(bundle: .module, name: "cookie")
		self.username = username
		self.text = text
	}
	
	///
	internal var url: URL {
		return .init(string: "https://www.buymeacoffee.com/\(self.username)")!
	}
}
