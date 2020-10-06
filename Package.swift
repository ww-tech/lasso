// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Lasso",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Lasso",
            targets: ["Lasso"]
        ),
        .library(
            name: "LassoTestUtilities",
            targets: ["LassoTestUtilities"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Lasso",
            dependencies: []
        ),
        .target(
            name: "LassoTestUtilities",
            dependencies: [
                .target(name: "Lasso")
            ]
        )
    ]
)
