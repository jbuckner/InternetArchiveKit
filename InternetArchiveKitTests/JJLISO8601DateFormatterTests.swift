//
//  FastISO8601DateFormatterTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 4/15/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit
import JJLISO8601DateFormatter

class JJLISO8601DateFormatterTests: XCTestCase {
  func testISODateParserCanParseGMT() {
    let isoDateParser = JJLISO8601DateFormatter()
    let isoFormatter = ISO8601DateFormatter()
    let comparisonISODate = isoFormatter.date(from: "2018-11-15T15:23:11Z")
    XCTAssertEqual(isoDateParser.date(from: "2018-11-15T15:23:11Z"), comparisonISODate)
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

  func testISODateParserGMTFormat() {
    let isoDateParser = JJLISO8601DateFormatter()
    XCTAssertNil(isoDateParser.date(from: "ABCD-AS-BATBA:AS:AS-AS:AS"))
  }

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
}
