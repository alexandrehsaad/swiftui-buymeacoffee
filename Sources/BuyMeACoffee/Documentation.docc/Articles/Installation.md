# Installation

Demonstrating how to use this package.

## Overview

Developers can use this package in their projects.

### Adding Dependency

Add the package to the dependencies in your `Package.swift` file.

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/alexandrehsaad/swiftui-buymeacoffee.git", branch: "main")
    ],
    ...
)
```

### Editing Target

Add the package as a dependency on your target in your `Package.swift` file.

```swift
let package = Package(
    ...
    targets: [
        .target(name: "MyTarget", dependencies: [
            .product(name: "BuyMeACoffee", package: "swiftui-buymeacoffee")
        ]),
    ],
    ...
)
```

### Importing Package

Import the package in your source code.

```swift
import BuyMeACoffee
```
