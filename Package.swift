// swift-tools-version:5.8
import PackageDescription

let package = Package(
  name: "InternetArchiveKit",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_13)
  ],
  products: [
    .library(name: "InternetArchiveKit", targets: ["InternetArchiveKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/michaeleisel/ZippyJSON", .upToNextMajor(from: "1.2.4")),
    .package(url: "https://github.com/michaeleisel/JJLISO8601DateFormatter", .upToNextMajor(from: "0.1.8")),
    .package(url: "https://github.com/azsn/URLSessionMock", .upToNextMajor(from: "0.1.0")),
  ],
  targets: [
    .target(
      name: "InternetArchiveKit",
      dependencies: ["JJLISO8601DateFormatter", "ZippyJSON"],
      path: "InternetArchiveKit",
      resources: [
        .process("PrivacyInfo.xcprivacy")]
    ),
    .testTarget(
      name: "InternetArchiveKitTests",
      dependencies: ["InternetArchiveKit", "JJLISO8601DateFormatter", "URLSessionMock"],
      path: "InternetArchiveKitTests"
    )
  ]
)
