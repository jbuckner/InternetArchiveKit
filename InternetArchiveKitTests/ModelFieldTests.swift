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


  func testDoubleSingleValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.ModelField<InternetArchive.IADouble>
    }

    let json: String = """
      { "foo": [1.2, 2.3] }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    do {
      let results: Foo = try JSONDecoder().decode(Foo.self, from: data)
      XCTAssertEqual(results.foo.values, [1.2, 2.3])
      XCTAssertEqual(results.foo.value, 1.2)
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


}
