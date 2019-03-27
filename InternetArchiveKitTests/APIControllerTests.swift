//
//  APIControllerTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

class APIControllerTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testGenerateSearchUrl() {
    let internetArchive: InternetArchive = InternetArchive(host: "foohost.org", scheme: "gopher", urlSession: URLSession.shared)
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar", "baz": "boop"])
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "foo", direction: .asc)
    if let url: URL = internetArchive.generateSearchUrl(query: query,
                                                      page: 0,
                                                      rows: 10,
                                                      fields: ["foo", "bar"],
                                                      sortFields: [sortField],
                                                      additionalQueryParams: []) {
      let absoluteUrl: String = url.absoluteString
      debugPrint(absoluteUrl)
      // these are not necessarily always in the same order so just search
      XCTAssertTrue(absoluteUrl.contains("sort%5B%5D=foo%20asc"))
      XCTAssertTrue(absoluteUrl.contains("fl%5B%5D=foo"))
      XCTAssertTrue(absoluteUrl.contains("fl%5B%5D=bar"))
      XCTAssertTrue(absoluteUrl.contains("q=foo:(bar)%20AND%20baz:(boop)") || absoluteUrl.contains("q=baz:(boop)%20AND%20foo:(bar)"))
      XCTAssertTrue(absoluteUrl.contains("output=json"))
      XCTAssertTrue(absoluteUrl.contains("rows=10"))
      XCTAssertTrue(absoluteUrl.contains("page=0"))
    } else {
      XCTFail("Error generating search URL")
    }
  }

  func testGenerateDownloadUrl() {
    let internetArchive: InternetArchive = InternetArchive(host: "foohost.org", scheme: "gopher", urlSession: URLSession.shared)
    if let url: URL = internetArchive.generateDownloadUrl(itemIdentifier: "foo", fileName: "bar") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/download/foo/bar")
    } else {
      XCTFail("Error generating download URL")
    }
  }

  func testGenerateImageUrl() {
    let internetArchive: InternetArchive = InternetArchive(host: "foohost.org", scheme: "gopher", urlSession: URLSession.shared)
    if let url: URL = internetArchive.generateItemImageUrl(itemIdentifier: "foo") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/services/img/foo")
    } else {
      XCTFail("Error generating download URL")
    }
  }
}
