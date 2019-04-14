//
//  ModelFieldTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

class ModelFieldTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testIAStringInit() {
    if let iaString: InternetArchive.IAString = InternetArchive.IAString(fromString: "foo") {
      XCTAssertEqual(iaString.value, "foo")
    } else {
      XCTFail("error initializing IAString")
    }
  }

  func testStringValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
      { "foo": "bar" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, ["bar"])
      XCTAssertEqual(results.foo.value, "bar")
    } catch {
      XCTFail("error decoding")
    }
  }

  func testArrayValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
      { "foo": ["bar", "boop"] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, ["bar", "boop"])
      XCTAssertEqual(results.foo.value, "bar")
    } catch {
      XCTFail("error decoding")
    }
  }

  func testTypeMismatchFailureSingleValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
      { "foo": 1 }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      _ = try JSONDecoder().decode(Foo.self, from: data)
      XCTFail("This should not have succeeded")
    } catch {
      XCTAssertTrue(error is Swift.DecodingError)
    }
  }

  func testTypeMismatchFailureArrayOfValues() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
      { "foo": [1, 2] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      _ = try JSONDecoder().decode(Foo.self, from: data)
      XCTFail("This should not have succeeded")
    } catch {
      XCTAssertTrue(error is Swift.DecodingError)
    }
  }

  func testIntSingleValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAInt>
    }

    let json: String = """
      { "foo": 1 }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [1])
      XCTAssertEqual(results.foo.value, 1)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIntArrayValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAInt>
    }

    let json: String = """
      { "foo": [1, 2] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [1, 2])
      XCTAssertEqual(results.foo.value, 1)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testBoolSingleValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IABool>
    }

    let json: String = """
      { "foo": true }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [true])
      XCTAssertEqual(results.foo.value, true)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testBoolArrayValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IABool>
    }

    let json: String = """
      { "foo": [true, false] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [true, false])
      XCTAssertEqual(results.foo.value, true)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testBoolStringArrayValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IABool>
    }

    let json: String = """
      { "foo": ["true", "false"] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [true, false])
      XCTAssertEqual(results.foo.value, true)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIADouble() {
    struct Foo: Decodable {
      let good: InternetArchive.ModelField<InternetArchive.IADouble>
      let bad: InternetArchive.ModelField<InternetArchive.IADouble>
    }

    let json: String = """
      { "good": [1.2, 2.3],
        "bad": "foo"
      }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.good.values, [1.2, 2.3])
      XCTAssertEqual(results.good.value, 1.2)

      XCTAssertNil(results.bad.value)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testDateSingleValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      { "foo": "2008-03-25" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    let comparisonDate1 = formatter.date(from: "2008-03-25")

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.foo.values, [comparisonDate1])
      XCTAssertEqual(results.foo.value, comparisonDate1)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testDateArray() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      { "foo": ["2008-03-25", "2018-12-30"] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    let comparisonDate1 = formatter.date(from: "2008-03-25")
    let comparisonDate2 = formatter.date(from: "2018-12-30")

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.foo.values, [comparisonDate1, comparisonDate2])
      XCTAssertEqual(results.foo.value, comparisonDate1)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testDateTime() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      { "foo": ["2008-03-25 14:51:24", "2018-12-30 09:12:32"] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    let comparisonDate1 = formatter.date(from: "2008-03-25 14:51:24")
    let comparisonDate2 = formatter.date(from: "2018-12-30 09:12:32")

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.foo.values, [comparisonDate1, comparisonDate2])
      XCTAssertEqual(results.foo.value, comparisonDate1)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testISO8601Date() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      { "foo": "2018-11-15T00:00:00Z" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let formatter = ISO8601DateFormatter()
    let comparisonDate1 = formatter.date(from: "2018-11-15T00:00:00Z")

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.foo.values, [comparisonDate1])
      XCTAssertEqual(results.foo.value, comparisonDate1)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testBadDate() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      { "foo": "baddate" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertNil(results.foo.value)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testISODateParsePerformance() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      { "foo": "2018-11-15T00:00:00Z" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    self.measure {
      for _ in 0..<1000 {
        do {
          _ = try JSONDecoder().decode(Foo.self, from: data)
        } catch {
          XCTFail("error decoding")
        }
      }
    }
  }

  func testFastISODateParseConcurrency() {
    let concurrentQueue = DispatchQueue(label: "fastParseTestQueue", attributes: .concurrent)
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADate>
    }

    for _ in 0..<1000 {
      let expectation = self.expectation(description: "concurrent wait")
      concurrentQueue.async {
        let year: Int = Int.random(in: 1000...2020)
        let month: Int = Int.random(in: 1...12)
        let day: Int = Int.random(in: 1...28)
        let hour: Int = Int.random(in: 1...12)
        let minute: Int = Int.random(in: 0..<60)
        let second: Int = Int.random(in: 0..<60)
        let randomISOString: String = "\(year)-\(month)-\(day)T\(hour):\(minute):\(second)Z"
        let json: String = """
        { "foo": "\(randomISOString)" }
        """
        guard let data: Data = json.data(using: .utf8) else {
          XCTFail("error encoding json to data")
          return
        }

        let formatter = ISO8601DateFormatter()
        let comparisonDate = formatter.date(from: randomISOString)

        do {
          let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
          XCTAssertEqual(results.foo.value, comparisonDate)
        } catch {
          XCTFail("error decoding")
        }
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
  }

  func testURL() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAURL>
    }

    let json: String = """
      { "foo": "http://yondermountainstringband.com" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let comparisonUrl = URL(string: "http://yondermountainstringband.com", relativeTo: nil)

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.foo.values, [comparisonUrl])
      XCTAssertEqual(results.foo.value, comparisonUrl)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testTimeInterval() {
    struct Foo: Decodable {
      let decimal: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let intString: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let int: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let double: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSeconds: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSecondsMinutes: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSecondsMinutesHours: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let badString1: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let badString2: InternetArchive.ModelField<InternetArchive.IATimeInterval>
    }

    let json: String = """
      {
        "decimal": "35.27",
        "intString": "45",
        "int": 25,
        "double": 19.13,
        "colonSeconds": "00:35",
        "colonSecondsMinutes": "23:11",
        "colonSecondsMinutesHours": "3:37:22",
        "badString1": "foo",
        "badString2": "a:b"
      }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let comparisonDecimal = TimeInterval(35.27)
    let comparisonIntString = TimeInterval(45)
    let comparisonInt = TimeInterval(25)
    let comparisonDouble = TimeInterval(19.13)
    let comparisonColonSeconds = TimeInterval(35)
    let comparisonColonSecondsMinutes = TimeInterval((23 * 60) + 11)
    let comparisonColonSecondsMinutesHours = TimeInterval((3 * 3600) + (37 * 60) + 22)
    let comparisonBadString = TimeInterval(0)

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.decimal.value, comparisonDecimal)
      XCTAssertEqual(results.intString.value, comparisonIntString)
      XCTAssertEqual(results.int.value, comparisonInt)
      XCTAssertEqual(results.double.value, comparisonDouble)
      XCTAssertEqual(results.colonSeconds.value, comparisonColonSeconds)
      XCTAssertEqual(results.colonSecondsMinutes.value, comparisonColonSecondsMinutes)
      XCTAssertEqual(results.colonSecondsMinutesHours.value, comparisonColonSecondsMinutesHours)
      XCTAssertEqual(results.badString1.value, comparisonBadString)
      XCTAssertEqual(results.badString2.value, comparisonBadString)
    } catch {
      XCTFail("error decoding")
    }
  }
}
