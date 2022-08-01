// BuyMeACoffeeButton+View.swift
// BuyMeACoffee
//
// Copyright © 2022 Alexandre H. Saad
// Licensed under Apache License v2.0 with Runtime Library Exception
//

import SwiftUI

extension BuyMeACoffeeButton: View {
	public var body: some View {
		return Link(destination: self.url) {
			Label {
				self.text
			} icon: {
				Image("buymeacoffee", bundle: .module)
			}
			.padding(.vertical, 5)
			.padding(.horizontal, 10)
		}
	}
}
