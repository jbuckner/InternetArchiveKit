//
//  StringOrArrayTests.swift
//  InternetArchiveSDKTests
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveSDK

class StringOrArrayTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testStringValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.StringOrArrayField
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
      XCTAssertEqual(results.foo.value, ["bar"])
    } catch {
      XCTFail("error decoding")
    }
  }

  func testArrayValue() {
    struct Foo: Decodable {
      let foo: InternetArchive.StringOrArrayField
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
      XCTAssertEqual(results.foo.value, ["bar", "boop"])
    } catch {
      XCTFail("error decoding")
    }
  }

  func testIntFailure() {
    struct Foo: Decodable {
      let foo: InternetArchive.StringOrArrayField
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

  func testIntArrayFailure() {
    struct Foo: Decodable {
      let foo: InternetArchive.StringOrArrayField
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


}
