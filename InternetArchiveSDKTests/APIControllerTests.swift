//
//  APIControllerTests.swift
//  InternetArchiveSDKTests
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveSDK

class APIControllerTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testGenerateSearchUrl() {
    let apiController: InternetArchive.APIController = InternetArchive.APIController(
      host: "foohost.org", scheme: "gopher")

    let query: InternetArchive.Query = InternetArchive.Query(fields: ["foo": "bar", "baz": "boop"])
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "foo", direction: .asc)
    if let url: URL = apiController.generateSearchUrl(query: query, start: 0, rows: 10, fields: ["foo", "bar"], sortFields: [sortField]) {
      let absoluteUrl: String = url.absoluteString
      debugPrint(absoluteUrl)
      // these are not necessarily always in the same order so just search
      XCTAssertTrue(absoluteUrl.contains("sort%5B%5D=foo%20asc"))
      XCTAssertTrue(absoluteUrl.contains("fl%5B%5D=foo"))
      XCTAssertTrue(absoluteUrl.contains("fl%5B%5D=bar"))
      XCTAssertTrue(absoluteUrl.contains("q=foo:(bar)%20AND%20baz:(boop)") || absoluteUrl.contains("q=baz:(boop)%20AND%20foo:(bar)"))
      XCTAssertTrue(absoluteUrl.contains("output=json"))
      XCTAssertTrue(absoluteUrl.contains("rows=10"))
      XCTAssertTrue(absoluteUrl.contains("start=0"))
    } else {
      XCTFail("Error generating search URL")
    }
  }

  func testGenerateDownloadUrl() {
    let apiController: InternetArchive.APIController = InternetArchive.APIController(
      host: "foohost.org", scheme: "gopher")
    if let url: URL = apiController.generateDownloadUrl(itemIdentifier: "foo", fileName: "bar") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/download/foo/bar")
    } else {
      XCTFail("Error generating download URL")
    }
  }

  func testQueryParamString() {
    let param1: InternetArchive.QueryParam = InternetArchive.QueryParam(key: "foo", value: "bar", booleanOperator: .and)
    XCTAssertEqual(param1.asURLParam, "foo:(bar)")
    let param2: InternetArchive.QueryParam = InternetArchive.QueryParam(key: "foo", value: "bar", booleanOperator: .not)
    XCTAssertEqual(param2.asURLParam, "-foo:(bar)")
    let param3: InternetArchive.QueryParam = InternetArchive.QueryParam(key: "", value: "bar", booleanOperator: .and)
    XCTAssertEqual(param3.asURLParam, "(bar)")
  }

  func testQueryString() {
    let param1: InternetArchive.QueryParam = InternetArchive.QueryParam(key: "foo", value: "bar", booleanOperator: .and)
    let param2: InternetArchive.QueryParam = InternetArchive.QueryParam(key: "baz", value: "boop", booleanOperator: .not)
    let param3: InternetArchive.QueryParam = InternetArchive.QueryParam(key: "", value: "boop")
    let query: InternetArchive.Query = InternetArchive.Query(params: [param1, param2, param3])

    XCTAssertEqual(query.asURLQuery, "foo:(bar) AND -baz:(boop) AND (boop)")
  }

  func testQueryStringConvenience() {
    let query: InternetArchive.Query = InternetArchive.Query(fields: ["foo": "bar", "baz": "boop"])
    let queryAsUrl: String = query.asURLQuery
    XCTAssertTrue(queryAsUrl == "foo:(bar) AND baz:(boop)" || queryAsUrl == "(bar) AND baz:(boop)")
    let query2: InternetArchive.Query = InternetArchive.Query(fields: ["": "bar", "baz": "boop"])
    let query2AsUrl: String = query2.asURLQuery
    XCTAssertTrue(query2AsUrl == "(bar) AND baz:(boop)" || query2AsUrl == "baz:(boop) AND (bar)")
  }

}
