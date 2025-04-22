// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SMSFilterSDK",
    platforms: [
        .iOS(.v14)  // Wymagana platforma iOS 14 lub nowsza (IdentityLookup od iOS 11 wzwyż)
    ],
    products: [
        .library(
            name: "SMSFilterSDK",
            targets: ["SMSFilterSDK"]
        )
    ],
    targets: [
        .target(
            name: "SMSFilterSDK",
            dependencies: []
        ),
        .testTarget(
            name: "SMSFilterSDKTests",
            dependencies: ["SMSFilterSDK"]
        )
    ]
)

