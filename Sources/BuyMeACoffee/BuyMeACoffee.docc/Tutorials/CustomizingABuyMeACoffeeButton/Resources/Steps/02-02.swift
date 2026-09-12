import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.plain)

        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.borderless)
    }
}
