// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "DashUIKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "DashUIKit", targets: ["DashUIKit"]),
    ],
    targets: [
        .target(
            name: "DashUIKit",
            resources: [
                .process("Resources/Media.xcassets"),
            ]
        ),
        .testTarget(
            name: "DashUIKitTests",
            dependencies: ["DashUIKit"]
        ),
    ]
)
