import BuyMeACoffee
import SwiftUI

#Preview {
    VStack {
        BuyMeACoffeeButton(username: "yourusername")
            .buttonStyle(.buyMeACoffee())
            .tint(.red) // No-op
            .foregroundStyle(.red, .red) // No-op
            .symbolRenderingMode(.hierarchical) // No-op
    }
}
