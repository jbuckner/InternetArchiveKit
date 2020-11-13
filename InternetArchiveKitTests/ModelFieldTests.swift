//
//  ModelFieldTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON
@testable import InternetArchiveKit

class ModelFieldTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testModelFieldSingleValuePerformance() {
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

    measure {
      for _ in 0..<1000 {
        _ = try? ZippyJSONDecoder().decode(Foo.self, from: data)
      }
    }

    measure {
      for _ in 0..<1000 {
        _ = try? JSONDecoder().decode(Foo.self, from: data)
      }
    }
  }

  func testModelFieldArrayValuePerformance() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
      { "foo": ["bar", "baz"] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    measure {
      for _ in 0..<1000 {
        _ = try? JSONDecoder().decode(Foo.self, from: data)
      }
    }

    measure {
      for _ in 0..<1000 {
        _ = try? ZippyJSONDecoder().decode(Foo.self, from: data)
      }
    }
  }

  func testIAStringStringInit() {
    if let iaString = InternetArchive.IAString(fromString: "foo") {
      XCTAssertEqual(iaString.value, "foo")
    } else {
      XCTFail("error initializing IAString")
    }
  }

  func testIAStringDecoder() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAString>
      let bar: InternetArchive.ModelField<InternetArchive.IAString>
    }

    let json: String = """
      { "foo": "bar", "bar": ["bar", "boop"] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, ["bar"])
      XCTAssertEqual(results.foo.value, "bar")

      XCTAssertEqual(results.bar.values, ["bar", "boop"])
      XCTAssertEqual(results.bar.value, "bar")
    } catch {
      XCTFail("error decoding")
    }
  }

  func testTypeMismatchFailure() {
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

  func testIAIntStringInit() {
    if let iaInt = InternetArchive.IAInt(fromString: "34") {
      XCTAssertEqual(iaInt.value, 34)
    } else {
      XCTFail("error initializing IAInt")
    }
  }

  func testIAIntDecoder() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IAInt>
      let bar: InternetArchive.ModelField<InternetArchive.IAInt>
      let baz: InternetArchive.ModelField<InternetArchive.IAInt>
      let bop: InternetArchive.ModelField<InternetArchive.IAInt>

      let bad: InternetArchive.ModelField<InternetArchive.IAInt>
    }

    let json: String = """
      { "foo": 1, "bar": "2", "baz": [3, 4], "bop": ["5", "6"], "bad": "abc" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [1])
      XCTAssertEqual(results.foo.value, 1)

      XCTAssertEqual(results.bar.values, [2])
      XCTAssertEqual(results.bar.value, 2)

      XCTAssertEqual(results.baz.values, [3, 4])
      XCTAssertEqual(results.baz.value, 3)

      XCTAssertEqual(results.bop.values, [5, 6])
      XCTAssertEqual(results.bop.value, 5)

      XCTAssertNil(results.bad.value)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIABoolStringInit() {
    if let iaBool = InternetArchive.IABool(fromString: "true") {
      XCTAssertEqual(iaBool.value, true)
    } else {
      XCTFail("error initializing IABool")
    }
  }

  func testIABoolDecoder() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IABool>
      let bar: InternetArchive.ModelField<InternetArchive.IABool>
      let baz: InternetArchive.ModelField<InternetArchive.IABool>
      let bop: InternetArchive.ModelField<InternetArchive.IABool>

      let bad: InternetArchive.ModelField<InternetArchive.IABool>
    }

    let json: String = """
      { "foo": true, "bar": "false", "baz": [true, false], "bop": ["false", "true"], "bad": "blep" }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [true])
      XCTAssertEqual(results.foo.value, true)

      XCTAssertEqual(results.bar.values, [false])
      XCTAssertEqual(results.bar.value, false)

      XCTAssertEqual(results.baz.values, [true, false])
      XCTAssertEqual(results.baz.value, true)

      XCTAssertEqual(results.bop.values, [false, true])
      XCTAssertEqual(results.bop.value, false)

      XCTAssertNil(results.bad.value)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIADoubleStringInit() {
    if let iaDouble = InternetArchive.IADouble(fromString: "35.34") {
      XCTAssertEqual(iaDouble.value, 35.34)
    } else {
      XCTFail("error initializing IADouble")
    }
  }

  func testIADoubleDecoder() {
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

  func testIADateStringInit() {
    if let iaDate = InternetArchive.IADate(fromString: "2018-11-15T15:23:11-02:30") {
      let isoFormatter = ISO8601DateFormatter()
      let comparisonISODate = isoFormatter.date(from: "2018-11-15T15:23:11-02:30")
      XCTAssertEqual(iaDate.value, comparisonISODate)
    } else {
      XCTFail("error initializing IADate")
    }
  }

  func testIADateDecoder() {
    struct Foo: Decodable {
      let year: InternetArchive.ModelField<InternetArchive.IADate>
      let yearMonth: InternetArchive.ModelField<InternetArchive.IADate>
      let yearMonthDay: InternetArchive.ModelField<InternetArchive.IADate>
      let yearBracket: InternetArchive.ModelField<InternetArchive.IADate>
      let yearCirca: InternetArchive.ModelField<InternetArchive.IADate>
      let dateTime: InternetArchive.ModelField<InternetArchive.IADate>
      let isoDate: InternetArchive.ModelField<InternetArchive.IADate>
      let isoDateTimeZoneOffset1: InternetArchive.ModelField<InternetArchive.IADate>
      let isoDateTimeZoneOffset2: InternetArchive.ModelField<InternetArchive.IADate>
      let badDate: InternetArchive.ModelField<InternetArchive.IADate>
    }

    let json: String = """
      {
        "year": "1957",
        "yearMonth": "1987-07",
        "yearMonthDay": "1993-03-14",
        "yearBracket": "[1968]",
        "yearCirca": "c.a. 1973",
        "dateTime": "2018-12-30 09:12:32",
        "isoDate": "2018-11-15T15:23:11Z",
        "isoDateTimeZoneOffset1": "2018-11-15T15:23:11-02:30",
        "isoDateTimeZoneOffset2": "2018-11-15T15:23:11+04:00",
        "badDate": "baddate"
      }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "GMT")

    formatter.dateFormat = "yyyy"
    let comparisonYear = formatter.date(from: "1957")

    formatter.dateFormat = "yyyy-MM"
    let comparisonYearMonth = formatter.date(from: "1987-07")

    formatter.dateFormat = "yyyy-MM-dd"
    let comparisonYearMonthDay = formatter.date(from: "1993-03-14")

    formatter.dateFormat = "'['yyyy']'"
    let comparisonYearBracket = formatter.date(from: "[1968]")

    formatter.dateFormat = "'c.a.' yyyy"
    let comparisonYearCirca = formatter.date(from: "c.a. 1973")

    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let comparisonDateTime = formatter.date(from: "2018-12-30 09:12:32")

    let isoFormatter = ISO8601DateFormatter()
    let comparisonISODate = isoFormatter.date(from: "2018-11-15T15:23:11Z")
    let comparisonISODateTimeZoneOffset1 = isoFormatter.date(from: "2018-11-15T15:23:11-02:30")
    let comparisonISODateTimeZoneOffset2 = isoFormatter.date(from: "2018-11-15T15:23:11+04:00")

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.year.value, comparisonYear)
      XCTAssertEqual(results.yearBracket.value, comparisonYearBracket)
      XCTAssertEqual(results.yearCirca.value, comparisonYearCirca)
      XCTAssertEqual(results.yearMonth.value, comparisonYearMonth)
      XCTAssertEqual(results.yearMonthDay.value, comparisonYearMonthDay)
      XCTAssertEqual(results.dateTime.value, comparisonDateTime)
      XCTAssertEqual(results.isoDate.value, comparisonISODate)
      XCTAssertEqual(results.isoDateTimeZoneOffset1.value, comparisonISODateTimeZoneOffset1)
      XCTAssertEqual(results.isoDateTimeZoneOffset2.value, comparisonISODateTimeZoneOffset2)
      XCTAssertNil(results.badDate.value)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIAURLStringInit() {
    if let iaUrl = InternetArchive.IAURL(fromString: "http://yondermountainstringband.com") {
      let comparisonUrl = URL(string: "http://yondermountainstringband.com")
      XCTAssertEqual(iaUrl.value, comparisonUrl)
    } else {
      XCTFail("error initializing IAURL")
    }
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

    let comparisonUrl = URL(string: "http://yondermountainstringband.com")

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)

      XCTAssertEqual(results.foo.values, [comparisonUrl])
      XCTAssertEqual(results.foo.value, comparisonUrl)
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIATimeIntervalStringInit() {
    if let iaTimeInterval = InternetArchive.IATimeInterval(fromString: "3:37:22") {
      let comparisonTimeInterval = TimeInterval((3 * 3600) + (37 * 60) + 22)
      XCTAssertEqual(iaTimeInterval.value, comparisonTimeInterval)
    } else {
      XCTFail("error initializing IATimeInterval")
    }
  }

  func testIATimeIntervalDecoder() {
    struct Foo: Decodable {
      let decimal: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let intString: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let int: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let double: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSeconds: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSecondsMinutes: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSecondsMinutesHours: InternetArchive.ModelField<InternetArchive.IATimeInterval>
      let colonSecondsMinutesHoursDecimal: InternetArchive.ModelField<InternetArchive.IATimeInterval>
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
        "colonSecondsMinutesHoursDecimal": "4:43:21.273",
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
    let comparisonColonSecondsMinutesHoursDecimal = TimeInterval((4 * 3600) + (43 * 60) + 21.273)
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
      XCTAssertEqual(results.colonSecondsMinutesHoursDecimal.value, comparisonColonSecondsMinutesHoursDecimal)
      XCTAssertEqual(results.badString1.value, comparisonBadString)
      XCTAssertEqual(results.badString2.value, comparisonBadString)
    } catch {
      XCTFail("error decoding")
    }
  }
}
