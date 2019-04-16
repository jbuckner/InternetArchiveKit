//
//  FastISO8601DateFormatterTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 4/15/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest

class FastISO8601DateFormatterTests: XCTestCase {
  func testISODateParserCanParseGMT() {
    let isoDateParser = FastISO8601GMTDateParser()
    let isoFormatter = ISO8601DateFormatter()
    let comparisonISODate = isoFormatter.date(from: "2018-11-15T15:23:11Z")
    XCTAssertEqual(isoDateParser.date(from: "2018-11-15T15:23:11Z"), comparisonISODate)
  }

  func testISODateParserDoesNotParseTimezoneOffset() {
    let isoDateParser = FastISO8601GMTDateParser()
    XCTAssertNil(isoDateParser.date(from: "2018-11-15T15:23:11-02:00"))
    XCTAssertNil(isoDateParser.date(from: "2018-11-15T15:23:11+04:30"))
  }

  func testISODateParserGMTFormat() {
    let isoDateParser = FastISO8601GMTDateParser()
    XCTAssertNil(isoDateParser.date(from: "ABCD-AS-BATBA:AS:AS-AS:AS"))
  }

  func testISODateParsePerformance() {
    let isoDateParser = FastISO8601GMTDateParser()
    self.measure {
      for _ in 0..<1000 {
        _ = isoDateParser.date(from: "2018-11-15T15:23:11Z")
      }
    }
  }

  func testFastISODateParseConcurrency() {
    let concurrentQueue = DispatchQueue(label: "fastParseTestQueue", attributes: .concurrent)
    let isoDateParser = FastISO8601GMTDateParser()
    for _ in 0..<1000 {
      let expectation = self.expectation(description: "concurrent wait")
      concurrentQueue.async {
        let year: Int = Int.random(in: 1000...2020)
        let month: Int = Int.random(in: 1...12)
        let day: Int = Int.random(in: 1...28)
        let hour: Int = Int.random(in: 1...12)
        let minute: Int = Int.random(in: 0..<60)
        let second: Int = Int.random(in: 0..<60)
        let randomISOString: String = String(format: "%04d-%02d-%02dT%02d:%02d:%02dZ", year, month, day, hour, minute, second)

        let formatter = ISO8601DateFormatter()
        let comparisonDate = formatter.date(from: randomISOString)

        if let date: Date = isoDateParser.date(from: randomISOString) {
          XCTAssertEqual(date, comparisonDate)
        } else {
          XCTFail("date was not parsed: \(randomISOString)")
        }
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
  }
}
