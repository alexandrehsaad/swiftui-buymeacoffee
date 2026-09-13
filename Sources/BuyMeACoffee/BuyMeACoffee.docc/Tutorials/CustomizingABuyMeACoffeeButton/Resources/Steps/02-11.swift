import BuyMeACoffee
import SwiftUI

#Preview {
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
