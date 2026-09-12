// This source file is part of the SwiftUI Buy Me a Coffee open source project
//
// Copyright (c) 2022-2026 Alexandre H. Saad
// Licensed under the MIT License
//
// See LICENSE.md for license information
// See CONTRIBUTORS.txt for the list of project authors

import SwiftUI

#Preview {
    let tints: Array<BuyMeACoffeeTint> = [.black, .white, .yellow]

    ScrollView {
        LazyVStack {
            Section {
                if #available(iOS 26, *) {
                    ForEach(DynamicTypeSize.allCases, id: \.self) { typeSize in
                        VStack {
                            BuyMeACoffeeButton(username: "myusername")
                                .buttonStyle(.glassProminent)
                                .tint(.blue)

                            BuyMeACoffeeButton(username: "myusername")
                                .buttonStyle(.buyMeACoffeeGlass(tint: .black))
                                .opacity(0.3)
                        }
                        .dynamicTypeSize(typeSize)
                    }
                }
            }
        }
        .scaleEffect(x: 0.8, y: 0.8)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
