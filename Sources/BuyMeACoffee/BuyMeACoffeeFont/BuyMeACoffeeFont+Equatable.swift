// BuyMeACoffeeFont+Equatable.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

extension BuyMeACoffeeFont: Equatable {
	public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
		return lhs.font == rhs.font
	}
}
