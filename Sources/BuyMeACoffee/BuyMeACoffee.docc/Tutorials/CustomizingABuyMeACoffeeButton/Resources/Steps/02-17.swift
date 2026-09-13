import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        ForEach(BuyMeACoffeeTint.allCases, id: \.self) { tint in
            BuyMeACoffeeButton(username: "yourusername")
                .buttonStyle(.buyMeACoffeeGlass(tint: tint))
        }
    }
}
