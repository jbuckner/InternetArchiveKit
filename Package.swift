// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "InternetArchiveKit",
  platforms: [
    .iOS(.v15),
    .macOS(.v12)
  ],
  products: [
    .library(name: "InternetArchiveKit", targets: ["InternetArchiveKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/michaeleisel/ZippyJSON", .upToNextMajor(from: "1.2.4")),
    .package(url: "https://github.com/michaeleisel/JJLISO8601DateFormatter", .upToNextMajor(from: "0.2.0")),
    .package(url: "https://github.com/azsn/URLSessionMock", .upToNextMajor(from: "0.1.0")),
    // documentation tooling only; adds no products to the library
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", .upToNextMajor(from: "1.3.0")),
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
      path: "InternetArchiveKitTests",
      // URLSessionMock exposes a mutable static (`mockEndpoints`) that isn't
      // Sendable; keep the tests in Swift 5 mode while the library is Swift 6.
      swiftSettings: [.swiftLanguageMode(.v5)]
    )
  ]
)
