// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "IQUITShared",
    // Specify supported platforms if needed
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the libraries a package produces, making them visible to other packages.
        .library(
            name: "IQUITShared",
            type: .dynamic,
            targets: ["IQUITShared"]
        )
    ],
    targets: [
        // Defines the main target for the IQUITShared module
        .target(
            name: "IQUITShared",
            path: "Sources/IQUITShared"
        )
    ]
)
