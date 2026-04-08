// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MixpanelSwiftCommon",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
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
