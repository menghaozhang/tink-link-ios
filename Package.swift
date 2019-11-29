// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TinkLinkSDK",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "TinkLinkSDK",
            targets: ["TinkLinkSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/grpc/grpc-swift.git", .exact("0.9.1"))
    ],
    targets: [
        .target(
            name: "TinkLinkSDK",
            dependencies: ["SwiftProtobuf", "SwiftGRPC"]
        ),
        .testTarget(
            name: "TinkLinkSDKTests",
            dependencies: ["TinkLinkSDK"]
        ),
    ]
)
