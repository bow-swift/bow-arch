// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "BowArch",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "BowArch", targets: ["BowArch"])
    ],

    dependencies: [
        .package(name: "Bow", url: "https://github.com/bow-swift/bow.git", .exact("0.8.0")),
    ],

    targets: [
        // Library targets
        .target(name: "BowArch",
                dependencies: [.product(name: "Bow", package: "Bow"),
                               .product(name: "BowEffects", package: "Bow"),
                               .product(name: "BowOptics", package: "Bow")]),
        // Test targets
        .testTarget(name: "BowArchTests",
                    dependencies: [.target(name: "BowArch")])
    ]
)
