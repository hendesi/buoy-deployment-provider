// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "buoy-deployment-provider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ConductivityDeploymentOption",
            targets: ["ConductivityDeploymentOption"]
        ),
        .executable(
            name: "ConductivityDeploymentTarget",
            targets: ["ConductivityDeploymentTarget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/Apodini.git", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(name: "ApodiniIoTDeploymentProvider", url: "https://github.com/Lerbert/ApodiniIoTDeploymentProvider", .branch("Expose-DeploymentTargetIoTCommon"))
    ],
    targets: [
        .target(
            name: "ConductivityDeploymentOption",
            dependencies: [
                .product(name: "ApodiniDeployBuildSupport", package: "Apodini"),
                .product(name: "DeploymentTargetIoTCommon", package: "ApodiniIoTDeploymentProvider")
            ]
        ),
        .executableTarget(
            name: "ConductivityDeploymentTarget",
            dependencies: [
                .target(name: "ConductivityDeploymentOption"),
                .product(name: "DeploymentTargetIoT", package: "ApodiniIoTDeploymentProvider"),
                .product(name: "DeploymentTargetIoTCommon", package: "ApodiniIoTDeploymentProvider")
            ]
        )
    ]
)
