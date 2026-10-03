//
//  AccessAndLicenseTests.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON
@testable import InternetArchiveKit

/// Mirrors the decoder `InternetArchive` uses for its own models.
private func snakeCaseDecoder() -> ZippyJSONDecoder {
  let decoder = ZippyJSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}

final class AccessFlagsTests: XCTestCase {

  func testPlainItemAllowsDownloads() {
    let flags = AccessFlags(collections: ["etree"], accessRestricted: nil, isDark: false)
    XCTAssertFalse(flags.isAccessRestricted)
    XCTAssertFalse(flags.isStreamOnly)
    XCTAssertFalse(flags.isDark)
    XCTAssertTrue(flags.allowsDownloads)
  }

  func testAccessRestrictedBlocksDownloads() {
    for text in ["true", "TRUE", "yes", "1"] {
      let flags = AccessFlags(collections: [], accessRestricted: text, isDark: false)
      XCTAssertTrue(flags.isAccessRestricted, text)
      XCTAssertFalse(flags.allowsDownloads, text)
    }
    XCTAssertFalse(
      AccessFlags(collections: [], accessRestricted: "false", isDark: false).isAccessRestricted)
  }

  func testStreamOnlyCollectionBlocksDownloads() {
    let flags = AccessFlags(
      collections: ["opensource_movies", "Stream_Only"], accessRestricted: nil, isDark: false)
    XCTAssertTrue(flags.isStreamOnly)
    XCTAssertFalse(flags.allowsDownloads)
  }

  func testDarkBlocksDownloads() {
    let flags = AccessFlags(collections: [], accessRestricted: nil, isDark: true)
    XCTAssertTrue(flags.isDark)
    XCTAssertFalse(flags.allowsDownloads)
  }

  func testCodableRoundTrip() throws {
    let flags = AccessFlags(collections: ["stream_only"], accessRestricted: "true", isDark: false)
    let data = try JSONEncoder().encode(flags)
    XCTAssertEqual(try JSONDecoder().decode(AccessFlags.self, from: data), flags)
  }
}

final class LicenseTests: XCTestCase {

  private func license(_ text: String) -> License {
    License(url: URL(string: text)!)
  }

  func testCreativeCommonsShortNames() {
    XCTAssertEqual(
      license("https://creativecommons.org/licenses/by-nc-nd/4.0/").shortName, "CC BY-NC-ND 4.0")
    XCTAssertEqual(
      license("http://creativecommons.org/licenses/by-nc-sa/3.0/us/").shortName, "CC BY-NC-SA 3.0")
    XCTAssertEqual(license("https://creativecommons.org/licenses/by/4.0").shortName, "CC BY 4.0")
    XCTAssertEqual(license("https://creativecommons.org/licenses/by").shortName, "CC BY")
    XCTAssertEqual(license("https://www.creativecommons.org/licenses/by-sa/2.0/").shortName, "CC BY-SA 2.0")
  }

  func testPublicDomainNames() {
    XCTAssertEqual(license("https://creativecommons.org/publicdomain/zero/1.0/").shortName, "CC0")
    XCTAssertEqual(
      license("http://creativecommons.org/licenses/publicdomain/").shortName, "Public Domain")
    XCTAssertEqual(
      license("https://creativecommons.org/publicdomain/mark/1.0/").shortName, "Public Domain")
    XCTAssertTrue(license("https://creativecommons.org/publicdomain/zero/1.0/").isPublicDomain)
    XCTAssertTrue(license("http://creativecommons.org/licenses/publicdomain/").isPublicDomain)
    XCTAssertFalse(license("https://creativecommons.org/licenses/by/4.0/").isPublicDomain)
  }

  func testOtherLicensesHaveNoShortName() {
    XCTAssertNil(license("https://example.org/terms").shortName)
    XCTAssertNil(license("https://creativecommons.org/").shortName)
    XCTAssertNil(license("https://creativecommons.org/about/").shortName)
    XCTAssertFalse(license("https://example.org/terms").isPublicDomain)
  }

  func testLicenseFromLiveMetadataFixture() throws {
    let dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let data = try Data(contentsOf: dir.appendingPathComponent("MockResponse/lenientMetadata.json"))
    let item = try snakeCaseDecoder().decode(InternetArchive.Item.self, from: data)
    let url = try XCTUnwrap(item.metadata?.licenseurl?.value)
    XCTAssertEqual(License(url: url).shortName, "Public Domain")
  }
}

final class ItemMetadataAccessKeysTests: XCTestCase {

  func testHyphenatedKeyAndLicenseurlDecode() throws {
    let json = """
      {"identifier": "x", "access-restricted-item": "true",
       "licenseurl": "https://creativecommons.org/licenses/by/4.0/", "is_dark": "true",
       "avg_rating": "4.5"}
      """
    let metadata = try snakeCaseDecoder().decode(
      InternetArchive.ItemMetadata.self, from: Data(json.utf8))
    XCTAssertEqual(metadata.accessRestrictedItem?.value, true)
    XCTAssertEqual(
      metadata.licenseurl?.value?.absoluteString, "https://creativecommons.org/licenses/by/4.0/")
    XCTAssertEqual(metadata.isDark?.value, "true")
    XCTAssertEqual(metadata.avgRating?.value, 4.5)
  }

  func testNewFieldsRoundTrip() throws {
    let metadata = InternetArchive.ItemMetadata(
      accessRestrictedItem: .init(values: [true]),
      identifier: "x",
      licenseurl: .init(values: [URL(string: "https://creativecommons.org/licenses/by/4.0/")!]))
    let data = try JSONEncoder().encode(metadata)
    XCTAssertTrue(String(decoding: data, as: UTF8.self).contains("\"access-restricted-item\":true"))
    let back = try snakeCaseDecoder().decode(InternetArchive.ItemMetadata.self, from: data)
    XCTAssertEqual(back.accessRestrictedItem?.value, true)
    XCTAssertEqual(back.licenseurl?.value, metadata.licenseurl?.value)
  }
}
