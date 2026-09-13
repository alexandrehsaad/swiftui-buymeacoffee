import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.glass)

        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.glassProminent)
    }
}
