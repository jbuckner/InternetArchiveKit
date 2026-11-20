//
//  StructuredFieldTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON

@testable import InternetArchiveKit

/// The field types that parse structure out of an Internet Archive string value.
class StructuredFieldTests: XCTestCase {

  private static let utc = TimeZone(secondsFromGMT: 0)!

  private func components(_ date: Date) -> DateComponents {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Self.utc
    return calendar.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: date)
  }

  // MARK: - Compact timestamps

  func testParsesCompactTimestamp() throws {
    // `scandate` on FRANCE24_20241031_063000
    let field = try XCTUnwrap(InternetArchive.IADate(fromString: "20241031063000"))
    let parts = components(try XCTUnwrap(field.value))
    XCTAssertEqual(parts.year, 2024)
    XCTAssertEqual(parts.month, 10)
    XCTAssertEqual(parts.day, 31)
    XCTAssertEqual(parts.hour, 6)
    XCTAssertEqual(parts.minute, 30)
    XCTAssertEqual(parts.second, 0)
  }

  func testParsesCompactDate() throws {
    // `sponsordate` on goody
    let field = try XCTUnwrap(InternetArchive.IADate(fromString: "20151231"))
    let parts = components(try XCTUnwrap(field.value))
    XCTAssertEqual(parts.year, 2015)
    XCTAssertEqual(parts.month, 12)
    XCTAssertEqual(parts.day, 31)
  }

  /// The compact formats sit above the bare-year parser precisely so this stays true:
  /// `DateFormatter` consumes what it can rather than requiring a full match, so an
  /// ordering mistake would turn `20151231` into January 2015 or `2018` into a nonsense date.
  func testBareYearStillParsesAsAYear() throws {
    let field = try XCTUnwrap(InternetArchive.IADate(fromString: "2018"))
    let parts = components(try XCTUnwrap(field.value))
    XCTAssertEqual(parts.year, 2018)
    XCTAssertEqual(parts.month, 1)
    XCTAssertEqual(parts.day, 1)
  }

  /// An all-numeric format matches the empty string and yields 2000-01-01, so the parser
  /// rejects blank input before any formatter sees it.
  func testBlankStringHasNoDate() {
    XCTAssertNil(DateParser.shared.date(from: ""))
    XCTAssertNil(DateParser.shared.date(from: "   "))
    XCTAssertNil(InternetArchive.IADate(fromString: "")?.value)
  }

  func testExistingDateFormatsStillParse() throws {
    let cases: [(String, Int, Int, Int)] = [
      ("2018-11-15T08:23:41Z", 2018, 11, 15),
      ("2018-03-25 14:51:24", 2018, 3, 25),
      ("2018-09-03", 2018, 9, 3),
      ("2018-09", 2018, 9, 1),
      ("[2018]", 2018, 1, 1),
      ("c.a. 2018", 2018, 1, 1),
    ]
    for (string, year, month, day) in cases {
      let field = try XCTUnwrap(
        InternetArchive.IADate(fromString: string), "failed to init for \(string)")
      let parts = components(try XCTUnwrap(field.value, "no value for \(string)"))
      XCTAssertEqual(parts.year, year, "year mismatch for \(string)")
      XCTAssertEqual(parts.month, month, "month mismatch for \(string)")
      XCTAssertEqual(parts.day, day, "day mismatch for \(string)")
    }
  }

  // MARK: - IAEpochDate

  func testEpochDateFromString() throws {
    let field = try XCTUnwrap(InternetArchive.IAEpochDate(fromString: "1581697658"))
    XCTAssertEqual(try XCTUnwrap(field.value).timeIntervalSince1970, 1_581_697_658)
  }

  func testEpochDateFromJSONNumber() throws {
    struct Foo: Decodable {
      let created: InternetArchive.ModelField<InternetArchive.IAEpochDate>
    }
    let data = #"{ "created": 1787425053 }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.created.value?.timeIntervalSince1970, 1_787_425_053)
  }

  func testEpochDateRejectsNonNumeric() {
    XCTAssertNil(InternetArchive.IAEpochDate(fromString: "not a date")?.value)
  }

  /// `EpochDate` wraps its `Date` rather than being one so that encoding doesn't go through
  /// the encoder's `dateEncodingStrategy`. A bare `Date` would round-trip wrong under the
  /// default strategy (seconds since 2001 read back as seconds since 1970, off by 31 years)
  /// and not at all under `.iso8601`. This has to hold whatever the caller configures.
  func testEpochDateRoundTripsUnderEveryDateEncodingStrategy() throws {
    struct Foo: Codable {
      let created: InternetArchive.ModelField<InternetArchive.IAEpochDate>
    }
    let seconds: TimeInterval = 1_785_214_429
    let data = #"{ "created": 1785214429 }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.created.value?.timeIntervalSince1970, seconds)

    let strategies: [(String, JSONEncoder.DateEncodingStrategy)] = [
      ("deferredToDate", .deferredToDate),
      ("iso8601", .iso8601),
      ("secondsSince1970", .secondsSince1970),
    ]
    for (name, strategy) in strategies {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = strategy
      let reEncoded = try encoder.encode(decoded)
      let reDecoded = try ZippyJSONDecoder().decode(Foo.self, from: reEncoded)
      XCTAssertEqual(
        reDecoded.created.value?.timeIntervalSince1970, seconds,
        "epoch date did not survive \(name)")
    }
  }

  /// The epoch fields are repeatable-shaped like any other, so the array path has to work.
  func testEpochDateDecodesAnArray() throws {
    struct Foo: Decodable {
      let stamps: InternetArchive.ModelField<InternetArchive.IAEpochDate>
    }
    let data = #"{ "stamps": ["1581697658", 1785214429] }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.stamps.values.count, 2)
    XCTAssertEqual(decoded.stamps.values[0].timeIntervalSince1970, 1_581_697_658)
    XCTAssertEqual(decoded.stamps.values[1].timeIntervalSince1970, 1_785_214_429)
  }

  // MARK: - IABool

  func testBoolAcceptsArchiveSpellings() {
    let truthy = ["true", "TRUE", "yes", "Yes", "1"]
    let falsy = ["false", "no", "No", "0"]
    for string in truthy {
      XCTAssertEqual(InternetArchive.IABool(fromString: string)?.value, true, string)
    }
    for string in falsy {
      XCTAssertEqual(InternetArchive.IABool(fromString: string)?.value, false, string)
    }
    XCTAssertNil(InternetArchive.IABool(fromString: "maybe")?.value)
  }

  func testBoolDecodesFromJSONBoolStringAndNumber() throws {
    struct Foo: Decodable {
      let a: InternetArchive.ModelField<InternetArchive.IABool>
      let b: InternetArchive.ModelField<InternetArchive.IABool>
      let c: InternetArchive.ModelField<InternetArchive.IABool>
    }
    let data = #"{ "a": true, "b": "yes", "c": 0 }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.a.value, true)
    XCTAssertEqual(decoded.b.value, true)
    XCTAssertEqual(decoded.c.value, false)
  }

  // MARK: - IAAspectRatio

  func testAspectRatio() throws {
    let field = try XCTUnwrap(InternetArchive.IAAspectRatio(fromString: "16:9"))
    let ratio = try XCTUnwrap(field.value)
    XCTAssertEqual(ratio.width, 16)
    XCTAssertEqual(ratio.height, 9)
    XCTAssertEqual(try XCTUnwrap(ratio.ratio), 16.0 / 9.0, accuracy: 0.0001)
    XCTAssertEqual(ratio.description, "16:9")
  }

  func testAspectRatioRejectsMalformed() {
    XCTAssertNil(InternetArchive.IAAspectRatio(fromString: "16")?.value)
    XCTAssertNil(InternetArchive.IAAspectRatio(fromString: "16:9:3")?.value)
    XCTAssertNil(InternetArchive.IAAspectRatio(fromString: "wide")?.value)
  }

  func testAspectRatioZeroHeightHasNoRatio() throws {
    let field = try XCTUnwrap(InternetArchive.IAAspectRatio(fromString: "16:0"))
    XCTAssertNil(try XCTUnwrap(field.value).ratio)
  }

  // MARK: - IACuration

  func testCurationParsesRealValue() throws {
    // verbatim from archive.org/metadata/etree
    let raw = "[curator]tracey pooh[/curator][date]20190109082229[/date][state]un-dark[/state]"
    let field = try XCTUnwrap(InternetArchive.IACuration(fromString: raw))
    let curation = try XCTUnwrap(field.value)
    XCTAssertEqual(curation.curator, "tracey pooh")
    XCTAssertTrue(curation.state == .undark)
    let parts = components(try XCTUnwrap(curation.date))
    XCTAssertEqual(parts.year, 2019)
    XCTAssertEqual(parts.month, 1)
    XCTAssertEqual(parts.day, 9)
    XCTAssertEqual(parts.hour, 8)
  }

  func testCurationParsesComment() throws {
    let raw = "[curator]bob[/curator][state]dark[/state][comment]spam, see ticket [42][/comment]"
    let curation = try XCTUnwrap(InternetArchive.IACuration(fromString: raw)?.value)
    XCTAssertEqual(curation.curator, "bob")
    XCTAssertTrue(curation.state == .dark)
    XCTAssertEqual(curation.comment, "spam, see ticket [42]")
  }

  func testCurationKeepsUnknownState() throws {
    let raw = "[curator]bob[/curator][state]quarantined[/state]"
    let curation = try XCTUnwrap(InternetArchive.IACuration(fromString: raw)?.value)
    XCTAssertNil(curation.state?.known)
    XCTAssertEqual(curation.state?.rawValue, "quarantined")
  }

  func testCurationRejectsUntaggedString() {
    XCTAssertNil(InternetArchive.IACuration(fromString: "just some words")?.value)
  }

  // MARK: - IAExternalIdentifier

  func testExternalIdentifier() throws {
    let field = try XCTUnwrap(
      InternetArchive.IAExternalIdentifier(fromString: "urn:isbn:0123456789"))
    let identifier = try XCTUnwrap(field.value)
    XCTAssertEqual(identifier.scheme, "isbn")
    XCTAssertEqual(identifier.value, "0123456789")
    XCTAssertEqual(identifier.description, "urn:isbn:0123456789")
  }

  /// The value keeps its own colons, so only the first two separators are split on.
  func testExternalIdentifierWithColonsInValue() throws {
    let raw = "urn:lcp:goody:epub:1cc7e3b8-ce40-4cf5-8050-91e376f826e8"
    let identifier = try XCTUnwrap(InternetArchive.IAExternalIdentifier(fromString: raw)?.value)
    XCTAssertEqual(identifier.scheme, "lcp")
    XCTAssertEqual(identifier.value, "goody:epub:1cc7e3b8-ce40-4cf5-8050-91e376f826e8")
    XCTAssertEqual(identifier.description, raw)
  }

  func testExternalIdentifierRejectsNonURN() {
    XCTAssertNil(InternetArchive.IAExternalIdentifier(fromString: "isbn:0123456789")?.value)
    XCTAssertNil(InternetArchive.IAExternalIdentifier(fromString: "urn:isbn")?.value)
    XCTAssertNil(InternetArchive.IAExternalIdentifier(fromString: "urn::0123456789")?.value)
  }

  // MARK: - Repeatable fields and round-tripping

  /// `external-identifier` is repeatable. The field wrapper has to rethrow on a non-string
  /// value so `ModelField` falls through to its array path; swallowing that error would
  /// leave every multi-value payload silently empty.
  func testExternalIdentifierDecodesAnArray() throws {
    struct Foo: Decodable {
      let ids: InternetArchive.ModelField<InternetArchive.IAExternalIdentifier>
    }
    let data = #"{ "ids": ["urn:isbn:0123456789", "urn:oclc:12345"] }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.ids.values.count, 2)
    XCTAssertEqual(decoded.ids.values[0].scheme, "isbn")
    XCTAssertEqual(decoded.ids.values[1].scheme, "oclc")
  }

  /// The structured types encode back to the string they were parsed from, so an encoded
  /// item keeps the shape the Archive serves and decodes again unchanged.
  func testStructuredTypesRoundTripAsStrings() throws {
    struct Foo: Codable {
      let aspectRatio: InternetArchive.ModelField<InternetArchive.IAAspectRatio>
      let curation: InternetArchive.ModelField<InternetArchive.IACuration>
      let externalIdentifier: InternetArchive.ModelField<InternetArchive.IAExternalIdentifier>
    }
    let json = #"""
      {
        "aspectRatio": "16:9",
        "curation": "[curator]tracey pooh[/curator][date]20190109082229[/date][state]un-dark[/state]",
        "externalIdentifier": "urn:lcp:goody:epub:1cc7e3b8"
      }
      """#.data(using: .utf8)!

    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: json)
    let reEncoded = try JSONEncoder().encode(decoded)

    // read the encoded values back as strings rather than matching the raw text:
    // JSONEncoder escapes the forward slashes in the curation tags
    let encoded = try XCTUnwrap(
      try JSONSerialization.jsonObject(with: reEncoded) as? [String: Any])
    XCTAssertEqual(encoded["aspectRatio"] as? String, "16:9")
    XCTAssertEqual(
      encoded["curation"] as? String,
      "[curator]tracey pooh[/curator][date]20190109082229[/date][state]un-dark[/state]")
    XCTAssertEqual(encoded["externalIdentifier"] as? String, "urn:lcp:goody:epub:1cc7e3b8")

    let reDecoded = try ZippyJSONDecoder().decode(Foo.self, from: reEncoded)
    XCTAssertEqual(reDecoded.aspectRatio.value?.width, 16)
    XCTAssertEqual(reDecoded.curation.value?.curator, "tracey pooh")
    XCTAssertEqual(reDecoded.curation.value?.date, decoded.curation.value?.date)
    XCTAssertTrue(reDecoded.curation.value?.state == .undark)
    XCTAssertEqual(reDecoded.externalIdentifier.value?.scheme, "lcp")
  }

  /// A string that doesn't parse leaves the field empty rather than failing the whole payload.
  func testMalformedStructuredValueDoesNotFailTheDecode() throws {
    struct Foo: Decodable {
      let name: String
      let aspectRatio: InternetArchive.ModelField<InternetArchive.IAAspectRatio>
    }
    let data = #"{ "name": "ok", "aspectRatio": "widescreen" }"#.data(using: .utf8)!
    let decoded = try ZippyJSONDecoder().decode(Foo.self, from: data)
    XCTAssertEqual(decoded.name, "ok")
    XCTAssertTrue(decoded.aspectRatio.values.isEmpty)
  }
}
