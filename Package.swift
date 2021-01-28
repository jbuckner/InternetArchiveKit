// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "InternetArchiveKit",
    platforms: [
      .iOS(.v12)
    ],
    products: [
      .library(name: "InternetArchiveKit", targets: ["InternetArchiveKit"])
    ],
    dependencies: [],
    targets: [
      .target(
        name: "InternetArchiveKit",
        path: "InternetArchiveKit"
      ),
      .testTarget(
        name: "InternetArchiveKitTests",
        dependencies: ["InternetArchiveKit"],
        path: "InternetArchiveKitTests"
      )
    ]
)
