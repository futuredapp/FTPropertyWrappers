// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FTPropertyWrappers",
    products: [
        .library(
            name: "FTPropertyWrappers",
            targets: ["FTPropertyWrappers"])
    ],
    targets: [
        .target(
            name: "FTPropertyWrappers",
            dependencies: []),
        .testTarget(
            name: "FTPropertyWrappersTests",
            dependencies: ["FTPropertyWrappers"])
    ]
)
