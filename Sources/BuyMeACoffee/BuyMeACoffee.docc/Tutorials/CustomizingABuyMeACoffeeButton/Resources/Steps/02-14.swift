import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        ForEach([ButtonSizing.fitted, .flexible], id: \.self) { size in
            BuyMeACoffeeButton(username: "yourusername")
                .buttonStyle(.buyMeACoffee())
                .buttonSizing(size)
        }
    }
    .frame(width: 256)
}
