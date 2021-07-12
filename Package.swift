// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "InternetArchiveKit",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_12)
  ],
  products: [
    .library(name: "InternetArchiveKit", targets: ["InternetArchiveKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/michaeleisel/ZippyJSON", from: "1.2.1"),
    .package(url: "https://github.com/michaeleisel/JJLISO8601DateFormatter", .upToNextMajor(from: "0.1.2")),
  ],
  targets: [
    .target(
      name: "InternetArchiveKit",
      dependencies: ["JJLISO8601DateFormatter", "ZippyJSON"],
      path: "InternetArchiveKit"
    ),
    .testTarget(
      name: "InternetArchiveKitTests",
      dependencies: ["InternetArchiveKit", "JJLISO8601DateFormatter"],
      path: "InternetArchiveKitTests"
    )
  ]
)
