//
//  IAEnumTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON

@testable import InternetArchiveKit

/// `IAEnum` has to give callers a real Swift enum without throwing away values the
/// Archive added after this library was built.
class IAEnumTests: XCTestCase {

  private typealias MediaTypeValue = InternetArchive.IAEnumValue<InternetArchive.MediaType>

  func testKnownValue() {
    let value = MediaTypeValue(rawValue: "etree")
    XCTAssertEqual(value.known, .etree)
    XCTAssertEqual(value.rawValue, "etree")
    XCTAssertEqual(value.description, "etree")
  }

  func testUnknownValueKeepsItsString() {
    let value = MediaTypeValue(rawValue: "hologram")
    XCTAssertNil(value.known)
    XCTAssertEqual(value.rawValue, "hologram")
  }

  /// The comparison ergonomics the model fields depend on. Both forms have to compile
  /// against an optional, because every field is `ModelField<…>?` with an optional `value`.
  func testComparisonAgainstCaseAndString() {
    let value: MediaTypeValue? = MediaTypeValue(rawValue: "etree")
    XCTAssertTrue(value == .etree)
    XCTAssertTrue(value == "etree")
    XCTAssertFalse(value == .audio)
    XCTAssertFalse(value == "audio")
    XCTAssertTrue(value != .audio)
    XCTAssertTrue(value != "audio")

    let missing: MediaTypeValue? = nil
    XCTAssertFalse(missing == .etree)
    XCTAssertFalse(missing == "etree")
    XCTAssertTrue(missing != .etree)
  }

  /// An unrecognized value matches on the wire string but never on a case.
  func testUnknownComparesByStringOnly() {
    let value: MediaTypeValue? = MediaTypeValue(rawValue: "hologram")
    XCTAssertTrue(value == "hologram")
    XCTAssertFalse(value == .etree)
  }

  func testDecodesSingleValue() throws {
    struct Foo: Decodable {
      let mediatype: InternetArchive.ModelField<InternetArchive.IAEnum<InternetArchive.MediaType>>
    }
    let data = #"{ "mediatype": "etree" }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.mediatype.value?.known, .etree)
  }

  func testDecodesArrayOfValues() throws {
    struct Foo: Decodable {
      let format: InternetArchive.ModelField<InternetArchive.IAEnum<InternetArchive.FileFormat>>
    }
    let data = #"{ "format": ["Flac", "VBR MP3", "Warp Core Dump"] }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.format.values.count, 3)
    XCTAssertEqual(decoded.format.values[0].known, .flac)
    XCTAssertEqual(decoded.format.values[1].known, .vbrMP3)
    XCTAssertNil(decoded.format.values[2].known)
    XCTAssertEqual(decoded.format.values[2].rawValue, "Warp Core Dump")
  }

  /// Losing an unrecognized value on re-encode would be the whole point missed.
  func testUnknownValueSurvivesRoundTrip() throws {
    struct Foo: Codable {
      let mediatype: InternetArchive.ModelField<InternetArchive.IAEnum<InternetArchive.MediaType>>
    }
    let data = #"{ "mediatype": "hologram" }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    let reEncoded = try JSONEncoder().encode(decoded)
    XCTAssertEqual(String(data: reEncoded, encoding: .utf8), #"{"mediatype":"hologram"}"#)

    let reDecoded = try ZippyJSONDecoder().decode(Foo.self, from: reEncoded)
    XCTAssertEqual(reDecoded.mediatype.value?.rawValue, "hologram")
  }

  func testEncodesAsBareString() throws {
    struct Foo: Codable {
      let mediatype: InternetArchive.ModelField<InternetArchive.IAEnum<InternetArchive.MediaType>>
    }
    let foo = Foo(mediatype: .init(values: [.known(.etree)]))
    let encoded = try JSONEncoder().encode(foo)
    XCTAssertEqual(String(data: encoded, encoding: .utf8), #"{"mediatype":"etree"}"#)
  }

  /// The raw values carry spaces, slashes and leading dashes, so a typo in one of them
  /// would leave a documented value decoding as `.unknown` forever.
  func testRawValuesMatchTheSchema() {
    XCTAssertEqual(InternetArchive.FileFormat.vbrMP3.rawValue, "VBR MP3")
    XCTAssertEqual(InternetArchive.FileFormat.h264.rawValue, "h.264")
    XCTAssertEqual(InternetArchive.FileFormat.unknownFormat.rawValue, "Unknown")
    XCTAssertEqual(InternetArchive.PageProgression.leftToRight.rawValue, "lr")
    XCTAssertEqual(InternetArchive.BookReaderDefaults.twoPage.rawValue, "mode/2up")
    XCTAssertEqual(InternetArchive.SortBy.addeddateDescending.rawValue, "-addeddate")
    XCTAssertEqual(InternetArchive.CurationState.undark.rawValue, "un-dark")
    XCTAssertEqual(InternetArchive.Condition.nearMint.rawValue, "Near Mint")
    XCTAssertEqual(InternetArchive.FileSource.derivative.rawValue, "derivative")
  }

  /// `FileFormat.unknownFormat` is the Archive's literal `"Unknown"` string and is a
  /// different thing from `IAEnumValue.unknown`, which means unrecognized.
  func testArchivesLiteralUnknownFormatIsAKnownCase() {
    let value = InternetArchive.IAEnumValue<InternetArchive.FileFormat>(rawValue: "Unknown")
    XCTAssertEqual(value.known, .unknownFormat)
  }

  func testEveryVocabularyHasDistinctRawValues() {
    assertDistinct(InternetArchive.MediaType.self)
    assertDistinct(InternetArchive.FileSource.self)
    assertDistinct(InternetArchive.FileFormat.self)
    assertDistinct(InternetArchive.PageProgression.self)
    assertDistinct(InternetArchive.Sound.self)
    assertDistinct(InternetArchive.Condition.self)
    assertDistinct(InternetArchive.ConditionVisual.self)
    assertDistinct(InternetArchive.BookReaderDefaults.self)
    assertDistinct(InternetArchive.SortBy.self)
    assertDistinct(InternetArchive.CurationState.self)
  }

  private func assertDistinct<T: IAEnumCase>(_ type: T.Type) {
    let raws = T.allCases.map(\.rawValue)
    XCTAssertEqual(Set(raws).count, raws.count, "\(type) has duplicate raw values")
  }
}
