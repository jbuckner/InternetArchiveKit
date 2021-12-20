// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "InternetArchiveKit",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_12)
  ],
  products: [
    .library(name: "InternetArchiveKit", targets: ["InternetArchiveKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/michaeleisel/ZippyJSON", .upToNextMajor(from: "1.2.4")),
    .package(url: "https://github.com/michaeleisel/JJLISO8601DateFormatter", .upToNextMajor(from: "0.1.2")),
    .package(url: "https://github.com/JohnSundell/AsyncCompatibilityKit", .upToNextMajor(from: "0.1.1")),
    .package(url: "https://github.com/azsn/URLSessionMock", .upToNextMajor(from: "0.1.0")),
  ],
  targets: [
    .target(
      name: "InternetArchiveKit",
      dependencies: ["JJLISO8601DateFormatter", "ZippyJSON", "AsyncCompatibilityKit"],
      path: "InternetArchiveKit"
    ),
    .testTarget(
      name: "InternetArchiveKitTests",
      dependencies: ["InternetArchiveKit", "JJLISO8601DateFormatter", "URLSessionMock"],
      path: "InternetArchiveKitTests"
    )
  ]
)
