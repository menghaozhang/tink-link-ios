// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TinkLink",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "TinkLink",
            targets: ["TinkLink"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/grpc/grpc-swift.git", .upToNextMajor(from: "0.9.1"))
    ],
    targets: [
        .target(
            name: "TinkLink",
            dependencies: ["SwiftProtobuf", "SwiftGRPC"]
        ),
        .testTarget(
            name: "TinkLinkTests",
            dependencies: ["TinkLink"]
        ),
    ]
)
