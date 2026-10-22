// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwA",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "SwACore", targets: ["SwACore"]),
    ],
    targets: [
        .target(name: "SwACore"),
        .testTarget(name: "SwACoreTests", dependencies: ["SwACore"]),
    ]
)
