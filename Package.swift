// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PXLFramework",
    platforms: [.macOS(.v13), .tvOS(.v16), .iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PXLFramework",
            targets: ["PXLFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/liltimtim/porkchop-ios.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PXLFramework",
            dependencies: [.product(name: "PorkChop", package: "porkchop-ios")]),
        .testTarget(
            name: "PXLFrameworkTests",
            dependencies: ["PXLFramework"]
        ),
    ]
)
