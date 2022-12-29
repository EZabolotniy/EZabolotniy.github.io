// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "EzabolotniyGithubIo",
    products: [
        .executable(
            name: "EzabolotniyGithubIo",
            targets: ["EzabolotniyGithubIo"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.7.0"),
        .package(url: "https://github.com/johnsundell/splashpublishplugin", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "EzabolotniyGithubIo",
            dependencies: [
              .product(name: "Publish", package: "Publish"),
              .product(name: "SplashPublishPlugin", package: "SplashPublishPlugin"),
            ]
        )
    ]
)
