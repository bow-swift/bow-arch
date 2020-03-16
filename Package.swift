// swift-tools-version:5.1

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
        .package(url: "https://github.com/bow-swift/bow.git", .branch("master")),
    ],

    targets: [
        // Library targets
        .target(name: "BowArch", dependencies: ["Bow", "BowEffects", "BowOptics"]),
        // Test targets
        .testTarget(name: "BowArchTests",
                    dependencies: ["BowArch"])
    ]
)
