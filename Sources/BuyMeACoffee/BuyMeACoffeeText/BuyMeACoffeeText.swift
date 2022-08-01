// BuyMeACoffeeText.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

///
public struct BuyMeACoffeeText {
	///
	internal let text: Text
	
	///
	///
	/// - parameter text:
	private init(_ text: Text) {
		self.text = text
	}
	
	// TODO: find or make an icon.
	/// The beer text.
	@available(swift 999)
	public static let beer: Self = .init(.init("buy_me_a_beer", bundle: .module))
	
	// TODO: localize text in more languages.
	/// The coffee text.
	public static let coffee: Self = .init(.init("buy_me_a_coffee", bundle: .module))
	
	// TODO: find or make an icon.
	/// The pizza text.
	@available(swift 999)
	public static let pizza: Self = .init(.init("buy_me_a_pizza", bundle: .module))
}
