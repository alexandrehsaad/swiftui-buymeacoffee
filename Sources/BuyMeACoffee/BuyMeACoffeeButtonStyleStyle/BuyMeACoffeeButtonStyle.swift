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
	internal let color: BuyMeACoffeeColor
	
	///
	internal let font: BuyMeACoffeeFont
	
	/// Creates a new instance with the specified tint and font.
	///
	/// - parameter tint:
	/// - parameter font:
	public init(
		tint: BuyMeACoffeeColor = .yellow,
		font: BuyMeACoffeeFont = .default
	) {
		self.color = tint
		self.font = font
	}
}
