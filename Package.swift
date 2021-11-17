// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DangerSwiftEda",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DangerSwiftEda",
            targets: ["DangerSwiftEda"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "3.0.0"),
        .package(name: "DangerSwiftHammer", url: "https://github.com/el-hoshino/DangerSwiftHammer", from: "0.2.0"),
        .package(name: "DangerSwiftShoki", url: "git@github.com:yumemi/danger-swift-shoki.git", .branch("feature/initial")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DangerSwiftEda",
            dependencies: [
                .product(name: "Danger", package: "danger-swift"),
                "DangerSwiftHammer",
                "DangerSwiftShoki",
            ]),
        .testTarget(
            name: "DangerSwiftEdaTests",
            dependencies: ["DangerSwiftEda"]),
    ]
)
