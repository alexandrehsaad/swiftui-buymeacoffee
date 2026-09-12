![](Tests/RepositorySnapshotTests/__Snapshots__/RepositorySnapshots/makeReadMeBanner.1.png)

# SwiftUI Buy Me a Coffee

A Swift package for creating branded [Buy Me a Coffee](https://www.buymeacoffee.com) links in SwiftUI.

## Overview

BuyMeACoffee provides a branded SwiftUI button that opens a creator's Buy Me a Coffee page. It includes solid and
Liquid Glass button styles, selectable tints, and an automatic contrasting border for light and dark
interfaces.

The button works with standard SwiftUI label styles and button border shapes, supports Dynamic Type and accessibility
settings, and can display localized text or the official Buy Me a Coffee logo alongside its matching icon.

## Requirements

- Swift 6.3+
- iOS 15+
- iPadOS 15+

BuyMeACoffee is written in Swift and is available on iOS platforms.

## Installation

1. Add BuyMeACoffee to the dependencies in your `Package.swift` file:

    ```swift
    let package: Package = .init(
        ...
        dependencies: [
            .package(
                url: "https://github.com/bikecalc/swiftui-buymeacoffee.git",
                from: "2.0.0"
            )
        ],
        ...
    )
    ```

2. Add the `BuyMeACoffee` product to the dependencies of the target that will import it. Replace `YourTarget` with the
   name of that target:

    ```swift
    let package: Package = .init(
        ...
        targets: [
            .target(
                name: "YourTarget",
                dependencies: [
                    .product(
                        name: "BuyMeACoffee",
                        package: "swiftui-buymeacoffee"
                    )
                ]
            )
        ],
        ...
    )
    ```

3. Import the package in your source code:

    ```swift
    import BuyMeACoffee
    ```
    
## Demonstration

```swift
BuyMeACoffeeButton(username: "myusername")
    .labelStyle(.titleAndIcon)
    .buttonStyle(.buyMeACoffeeGlass(tint: .yellow))
```

The code above renders the button below. Click it to visit my Buy Me a Coffee page.

<a href="https://www.buymeacoffee.com/alexandrehsaad">
    <img
        src="Tests/RepositorySnapshotTests/__Snapshots__/RepositorySnapshots/makeBuyMeACoffeeButton.1.png"
        alt="Buy me a coffee"
        height="72"
    >
</a>

## Documentation

You can read more about this package by visiting the
[documentation](https://alexandrehsaad.github.io/swiftui-buymeacoffee/documentation/buymeacoffee).

## License

Distributed under the [MIT License](LICENSE.md). See the [third-party notices](THIRD_PARTY_NOTICES.md) for materials 
covered by separate terms.

This is an independent, unofficial project and is not affiliated with, sponsored by, or endorsed by Buy Me a Coffee. The
Buy Me a Coffee name, logo, and related artwork belong to Buy Me a Coffee and are not licensed under this project's MIT
License.

This repository is a personal educational portfolio project created to explore various technologies. It is distributed
without charge and is not intended to suggest a commercial relationship with Buy Me a Coffee.
