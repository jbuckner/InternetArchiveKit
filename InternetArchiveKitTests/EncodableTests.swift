//
//  EncodableTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON

@testable import InternetArchiveKit

/// The models encode back to JSON that decodes into the same values, so
/// responses can be cached and re-read.
class EncodableTests: XCTestCase {

  func testModelFieldRoundTrip() throws {
    struct Foo: Codable {
      let foo: InternetArchive.ModelField<InternetArchive.IAInt>
      let bar: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
        { "foo": "3", "bar": ["boop", "bop"] }
      """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let decoded: Foo = try ZippyJSONDecoder().decode(Foo.self, from: data)
    let reEncoded: Data = try JSONEncoder().encode(decoded)
    let reDecoded: Foo = try ZippyJSONDecoder().decode(Foo.self, from: reEncoded)

    XCTAssertEqual(reDecoded.foo.values, [3])
    XCTAssertEqual(reDecoded.bar.values, ["boop", "bop"])
  }

  func testSingleValueEncodesBare() throws {
    struct Foo: Codable {
      let foo: InternetArchive.ModelField<InternetArchive.IAInt>
    }

    let foo = Foo(foo: InternetArchive.ModelField<InternetArchive.IAInt>(values: [3]))
    let encoded: Data = try JSONEncoder().encode(foo)
    XCTAssertEqual(String(data: encoded, encoding: .utf8), "{\"foo\":3}")
  }

  func testItemMetadataRoundTrip() throws {
    let json: String = """
        {
          "identifier": "sci2007-07-28.Schoeps",
          "title": "String Cheese Incident Live",
          "date": "2007-07-28T00:00:00Z",
          "venue": ["Red Rocks"]
        }
      """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let decoded: InternetArchive.ItemMetadata = try ZippyJSONDecoder().decode(
      InternetArchive.ItemMetadata.self, from: data)

    let encoder = JSONEncoder()
    // IADate parses ISO 8601, so this keeps encoded dates re-decodable
    encoder.dateEncodingStrategy = .iso8601
    let reEncoded: Data = try encoder.encode(decoded)
    let reDecoded: InternetArchive.ItemMetadata = try ZippyJSONDecoder().decode(
      InternetArchive.ItemMetadata.self, from: reEncoded)

    XCTAssertEqual(reDecoded.identifier, "sci2007-07-28.Schoeps")
    XCTAssertEqual(reDecoded.title.flatMap { $0.value }, "String Cheese Incident Live")
    XCTAssertEqual(reDecoded.venue.flatMap { $0.value }, "Red Rocks")
    XCTAssertEqual(reDecoded.date.flatMap { $0.value }, decoded.date.flatMap { $0.value })
  }

  /// The fields this release added have to survive a cache round-trip too: an enum whose
  /// value the Archive introduced later, a hyphenated wire key, and a parsed blob.
  func testItemMetadataRoundTripsNewFieldTypes() throws {
    let json: String = """
      {
        "identifier": "etree",
        "mediatype": "collection",
        "page-progression": "lr",
        "identifier-access": "http://archive.org/details/etree",
        "external-identifier": "urn:lcp:goody:epub:1cc7e3b8",
        "aspect_ratio": "16:9",
        "closed_captioning": "no",
        "scandate": "20241031063000",
        "curation": "[curator]tracey pooh[/curator][state]un-dark[/state]"
      }
      """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let decoder = ZippyJSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let decoded = try decoder.decode(InternetArchive.ItemMetadata.self, from: data)

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let reEncoded: Data = try encoder.encode(decoded)
    let reDecoded = try decoder.decode(InternetArchive.ItemMetadata.self, from: reEncoded)

    XCTAssertTrue(reDecoded.mediatype?.value == .collection)
    XCTAssertTrue(reDecoded.pageProgression?.value == .leftToRight)
    XCTAssertEqual(
      reDecoded.identifierAccess?.value?.absoluteString, "http://archive.org/details/etree")
    XCTAssertEqual(reDecoded.externalIdentifier?.value?.scheme, "lcp")
    XCTAssertEqual(reDecoded.aspectRatio?.value?.width, 16)
    XCTAssertEqual(reDecoded.closedCaptioning?.value, false)
    XCTAssertEqual(reDecoded.scandate?.value, decoded.scandate?.value)
    XCTAssertEqual(reDecoded.curation?.value?.curator, "tracey pooh")
  }
}
