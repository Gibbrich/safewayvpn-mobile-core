// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "XrayCoreKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "XrayCoreKit",
            targets: ["XrayCoreKit", "XrayCore"]
        ),
    ],
    targets: [
        .target(
            name: "XrayCoreKit",
            dependencies: ["XrayCore"]
        ),
        .binaryTarget(
            name: "XrayCore",
            url: "https://github.com/Gibbrich/safewayvpn-mobile-core/releases/download/v1.0.0/XrayCore.xcframework.zip",
            checksum: "8756f84ae14fa852e1d4b38dad50747479abf8bd0df1c53b886e5818423ca0fd"
        )
    ]
)