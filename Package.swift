// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MixpanelSwiftCommon",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12),
        .watchOS(.v9),
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
