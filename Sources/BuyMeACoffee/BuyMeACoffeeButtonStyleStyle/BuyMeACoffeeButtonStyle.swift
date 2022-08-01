// BuyMeACoffeeButtonStyle.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

///
public struct BuyMeACoffeeButtonStyle {
	///
	@Environment(\.colorScheme)
	internal var colorScheme: ColorScheme
	
//	///
//	internal let tint: BuyMeACoffeeController = .init()
	
	///
	internal let font: BuyMeACoffeeFont

	///
	internal let tint: BuyMeACoffeeColor
	
	/// Creates a new instance with the specified font and tint.
	///
	/// - parameter font:
	/// - parameter tint:
	public init(
		font: BuyMeACoffeeFont = .default,
		tint: BuyMeACoffeeColor = .yellow
	) {
		self.font = font
		self.tint = tint
	}
}
