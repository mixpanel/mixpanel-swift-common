// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MixpanelSwiftCommon",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS(.v10_13),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "MixpanelSwiftCommon",
            targets: ["MixpanelSwiftCommon"]
        )
    ],
    targets: [
        .target(
            name: "MixpanelSwiftCommon",
            dependencies: []
        ),
        .testTarget(
            name: "MixpanelSwiftCommonTests",
            dependencies: ["MixpanelSwiftCommon"],
            resources: [.copy("test-data")]
        )
    ]
)
