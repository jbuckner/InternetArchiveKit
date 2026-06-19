//
//  JJLISO8601DateFormatterTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 4/15/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit
import JJLISO8601DateFormatter

// JJLISO8601DateFormatter is a faster, drop-in replacement for Foundation's
// ISO8601DateFormatter. These tests pin its behavior to Apple's formatter in both
// directions — String -> Date parsing and Date -> String formatting — so a dependency
// bump can be validated as genuinely drop-in rather than assumed to be.
//
// JJL only supports the Gregorian calendar (instants on/after 1583), so all fixtures
// use modern dates.
class JJLISO8601DateFormatterTests: XCTestCase {

  // A fixed instant reused across tests: 2018-11-15T15:23:11Z.
  private let referenceEpoch: TimeInterval = 1542295391

  // MARK: - Parsing (String -> Date)

  func testISODateParserCanParseGMT() {
    let isoDateParser = JJLISO8601DateFormatter()
    let isoFormatter = ISO8601DateFormatter()
    let comparisonISODate = isoFormatter.date(from: "2018-11-15T15:23:11Z")
    XCTAssertEqual(isoDateParser.date(from: "2018-11-15T15:23:11Z"), comparisonISODate)
  }

  // Pins the parsed instant to an absolute epoch, independent of Apple's formatter, so
  // the contract holds even if both implementations were to drift together.
  func testISODateParserParsesToExpectedEpoch() {
    let isoDateParser = JJLISO8601DateFormatter()
    XCTAssertEqual(isoDateParser.date(from: "2018-11-15T15:23:11Z"),
                   Date(timeIntervalSince1970: referenceEpoch))
  }

  func testISODateParserHandlesTimezoneOffset() {
    let appleFormatter = ISO8601DateFormatter()
    let jjlFormatter = JJLISO8601DateFormatter()
    let dates = ["2018-11-15T15:23:11-02:00", "2018-11-15T15:23:11+04:30"]
    for date in dates {
      let comparisonDate = appleFormatter.date(from: date)
      XCTAssertEqual(jjlFormatter.date(from: date), comparisonDate)
    }
  }

  // Broader offset matrix: zulu, zero offset, the issue's -07:00, half-hour offsets,
  // and the extreme valid bounds.
  func testISODateParserMatchesAppleAcrossOffsets() {
    let appleFormatter = ISO8601DateFormatter()
    let jjlFormatter = JJLISO8601DateFormatter()
    let offsets = ["Z", "+00:00", "-07:00", "+05:30", "-12:00", "+14:00"]
    for offset in offsets {
      let string = "2018-11-15T15:23:11\(offset)"
      let comparisonDate = appleFormatter.date(from: string)
      XCTAssertNotNil(comparisonDate, "Apple failed to parse \(string)")
      XCTAssertEqual(jjlFormatter.date(from: string), comparisonDate, "mismatch for \(string)")
    }
  }

  func testISODateParserHandlesFractionalSeconds() {
    let appleFormatter = ISO8601DateFormatter()
    appleFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let jjlFormatter = JJLISO8601DateFormatter()
    jjlFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let dates = ["2018-11-15T15:23:11.123Z", "2018-11-15T15:23:11.123-07:00"]
    for date in dates {
      let comparisonDate = appleFormatter.date(from: date)
      XCTAssertNotNil(comparisonDate)
      XCTAssertEqual(jjlFormatter.date(from: date), comparisonDate)
    }
  }

  func testISODateParserHandlesLeapDay() {
    let appleFormatter = ISO8601DateFormatter()
    let jjlFormatter = JJLISO8601DateFormatter()
    let leapDay = "2020-02-29T23:59:59Z"
    let comparisonDate = appleFormatter.date(from: leapDay)
    XCTAssertNotNil(comparisonDate)
    XCTAssertEqual(jjlFormatter.date(from: leapDay), comparisonDate)
  }

  func testISODateParserGMTFormat() {
    let isoDateParser = JJLISO8601DateFormatter()
    XCTAssertNil(isoDateParser.date(from: "ABCD-AS-BATBA:AS:AS-AS:AS"))
  }

  // Malformed and incomplete inputs must behave exactly as Apple's formatter does —
  // all nil under the default .withInternetDateTime options.
  func testISODateParserMatchesAppleOnMalformedInput() {
    let appleFormatter = ISO8601DateFormatter()
    let jjlFormatter = JJLISO8601DateFormatter()
    let inputs = ["", "not a date", "2018", "2018-11-15", "15:23:11Z", "2018/11/15 15:23:11"]
    for input in inputs {
      let comparisonDate = appleFormatter.date(from: input)
      XCTAssertNil(comparisonDate, "Apple unexpectedly parsed '\(input)'")
      XCTAssertEqual(jjlFormatter.date(from: input), comparisonDate, "mismatch for '\(input)'")
    }
  }

  // MARK: - Formatting (Date -> String), the 0.2.0 fast path

  func testStringFromDateMatchesAppleDefaultOptions() {
    let date = Date(timeIntervalSince1970: referenceEpoch)
    assertStringEquivalent(date: date, options: .withInternetDateTime)
  }

  func testStringFromDateMatchesAppleWithFractionalSeconds() {
    let date = Date(timeIntervalSince1970: referenceEpoch + 0.123)
    assertStringEquivalent(date: date, options: [.withInternetDateTime, .withFractionalSeconds])
  }

  func testStringFromDateMatchesAppleAcrossFormatOptions() {
    let appleParser = ISO8601DateFormatter()
    let dates = [
      appleParser.date(from: "2018-11-15T15:23:11Z")!,
      appleParser.date(from: "2000-01-01T00:00:00Z")!,
      appleParser.date(from: "2020-02-29T23:59:59Z")!
    ]
    let optionSets: [ISO8601DateFormatter.Options] = [
      .withInternetDateTime,
      .withFullDate,
      .withFullTime,
      [.withFullDate, .withFullTime, .withSpaceBetweenDateAndTime]
    ]
    for date in dates {
      for options in optionSets {
        assertStringEquivalent(date: date, options: options)
      }
    }
  }

  func testStringFromDateRespectsTimeZone() {
    let date = Date(timeIntervalSince1970: referenceEpoch)
    let zones = [
      TimeZone(secondsFromGMT: 0)!,
      TimeZone(secondsFromGMT: -7 * 3600)!,
      TimeZone(secondsFromGMT: 5 * 3600 + 1800)!
    ]
    for zone in zones {
      assertStringEquivalent(date: date, options: .withInternetDateTime, timeZone: zone)
    }
  }

  func testStaticStringFromDateMatchesApple() {
    let date = Date(timeIntervalSince1970: referenceEpoch)
    let zone = TimeZone(secondsFromGMT: 0)!
    let jjlString = JJLISO8601DateFormatter.string(from: date, timeZone: zone, formatOptions: .withInternetDateTime)
    let appleString = ISO8601DateFormatter.string(from: date, timeZone: zone, formatOptions: .withInternetDateTime)
    XCTAssertEqual(jjlString, appleString)
  }

  // MARK: - Round trip

  func testDateToStringToDateRoundTrip() {
    let formatter = JJLISO8601DateFormatter()
    let original = Date(timeIntervalSince1970: referenceEpoch) // whole seconds -> exact
    let string = formatter.string(from: original)
    XCTAssertEqual(formatter.date(from: string), original)
  }

  // MARK: - Performance & concurrency

  func testISODateParsePerformance() {
    let isoDateParser = JJLISO8601DateFormatter()
    self.measure {
      for _ in 0..<1000 {
        _ = isoDateParser.date(from: "2018-11-15T15:23:11Z")
      }
    }
  }

  func testJJLISODateParseConcurrency() {
    let concurrentQueue = DispatchQueue(label: "fastParseTestQueue", attributes: .concurrent)
    let fastFormatter = JJLISO8601DateFormatter()
    let appleFormatter = ISO8601DateFormatter()
    let gregorianStart = 1583

    for _ in 0..<1000 {
      let expectation = self.expectation(description: "concurrent wait")
      concurrentQueue.async {
        // JJL doesn't work before 1583 because that's when the
        // Gregorian calendar started and, for performance,
        // doesn't support prior calendars
        let year: Int = Int(arc4random_uniform(2020)) + gregorianStart
        let month: Int = Int(arc4random_uniform(11)) + 1
        let day: Int = Int(arc4random_uniform(27)) + 1
        let hour: Int = Int(arc4random_uniform(11)) + 1
        let minute: Int = Int(arc4random_uniform(59))
        let second: Int = Int(arc4random_uniform(59))
        let randomISOString: String = String(format: "%04d-%02d-%02dT%02d:%02d:%02dZ", year, month, day, hour, minute, second)

        let comparisonDate = appleFormatter.date(from: randomISOString)

        if let date: Date = fastFormatter.date(from: randomISOString) {
          XCTAssertEqual(date, comparisonDate)
        } else {
          XCTFail("date was not parsed: \(randomISOString)")
        }
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 20, handler: nil)
  }

  // MARK: - Helpers

  // Asserts JJL and Apple produce identical strings for the same date/options/zone.
  // String equality sidesteps floating-point precision concerns: both formatters
  // operate on the same Date and round identically.
  private func assertStringEquivalent(
    date: Date,
    options: ISO8601DateFormatter.Options,
    timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let apple = ISO8601DateFormatter()
    apple.formatOptions = options
    apple.timeZone = timeZone
    let jjl = JJLISO8601DateFormatter()
    jjl.formatOptions = options
    jjl.timeZone = timeZone
    XCTAssertEqual(jjl.string(from: date), apple.string(from: date), file: file, line: line)
  }
}
