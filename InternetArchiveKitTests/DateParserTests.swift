//
//  DateParserTests.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

// DateParser is the production consumer of JJLISO8601DateFormatter. It walks a chain of
// formatters — ISO8601 first, then a series of DateFormatter patterns — so that IA
// metadata dates, which arrive in several shapes, all decode to a Date. These tests
// drive the parser directly (no JSON layer) to pin every supported shape and the nil
// cases, isolating the parser from the ModelField / ZippyJSON decode path.
class DateParserTests: XCTestCase {
  private let parser = DateParser.shared

  // Mirrors DateParser's own fallback formatters (fixed-pattern, GMT) for comparisons.
  private func gmtFormatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }

  // A full ISO8601 timestamp is handled by the JJL formatter at the head of the chain.
  // Asserting the absolute epoch also proves ISO8601 wins over the looser yyyy-based
  // patterns later in the chain (a year-only parse would yield 2018-01-01, not this).
  func testParsesISO8601Zulu() {
    XCTAssertEqual(parser.date(from: "2018-11-15T15:23:11Z"),
                   Date(timeIntervalSince1970: 1542295391))
  }

  func testParsesISO8601WithTimeZoneOffset() {
    let apple = ISO8601DateFormatter()
    XCTAssertEqual(parser.date(from: "2018-11-15T15:23:11-02:30"),
                   apple.date(from: "2018-11-15T15:23:11-02:30"))
  }

  func testParsesYearOnly() {
    XCTAssertEqual(parser.date(from: "1957"),
                   gmtFormatter("yyyy").date(from: "1957"))
  }

  func testParsesYearMonth() {
    XCTAssertEqual(parser.date(from: "1987-07"),
                   gmtFormatter("yyyy-MM").date(from: "1987-07"))
  }

  func testParsesYearMonthDay() {
    XCTAssertEqual(parser.date(from: "1993-03-14"),
                   gmtFormatter("yyyy-MM-dd").date(from: "1993-03-14"))
  }

  func testParsesSpaceSeparatedDateTime() {
    XCTAssertEqual(parser.date(from: "2018-12-30 09:12:32"),
                   gmtFormatter("yyyy-MM-dd HH:mm:ss").date(from: "2018-12-30 09:12:32"))
  }

  func testParsesBracketedYear() {
    XCTAssertEqual(parser.date(from: "[1968]"),
                   gmtFormatter("'['yyyy']'").date(from: "[1968]"))
  }

  func testParsesCircaYear() {
    XCTAssertEqual(parser.date(from: "c.a. 1973"),
                   gmtFormatter("'c.a.' yyyy").date(from: "c.a. 1973"))
  }

  func testReturnsNilForGarbage() {
    XCTAssertNil(parser.date(from: "baddate"))
  }

  func testReturnsNilForEmptyString() {
    XCTAssertNil(parser.date(from: ""))
  }
}
