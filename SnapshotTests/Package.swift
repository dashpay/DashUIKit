// swift-tools-version: 6.3
// Snapshot tests for DashUIKit, in a package of their own so that the library's manifest,
// and what its consumers resolve, never include the snapshot library. See
// docs/snapshot-tests.md.
import PackageDescription

let package = Package(
    name: "DashUIKitSnapshotTests",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    dependencies: [
        .package(name: "DashUIKit", path: ".."),
        // Bump by hand to a release at least two weeks old, then re-record (see the docs).
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.19.6"),
    ],
    targets: [
        .testTarget(
            name: "DashUIKitSnapshotTests",
            dependencies: [
                "DashUIKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: ["__Snapshots__"]
        ),
    ]
)
