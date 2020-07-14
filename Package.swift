// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "BouncyLayout",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "BouncyLayout", targets: ["BouncyLayout"])
    ],
    targets: [
        .target(
            name: "BouncyLayout",
            path: "BouncyLayout"
        )
    ],
    swiftLanguageVersions: [.v5]
)
