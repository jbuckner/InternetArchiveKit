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

  func testGenerateSearchUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar", "baz": "boop"])
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "foo", direction: .asc)
    if let url: URL = urlGenerator.generateSearchUrl(query: query,
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
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    if let url: URL = urlGenerator.generateDownloadUrl(itemIdentifier: "foo", fileName: "bar") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/download/foo/bar")
    } else {
      XCTFail("Error generating download URL")
    }
  }

  func testGenerateImageUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    if let url: URL = urlGenerator.generateItemImageUrl(itemIdentifier: "foo") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/services/img/foo")
    } else {
      XCTFail("Error generating download URL")
    }
  }

  func testGenerateMetadataUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    if let url: URL = urlGenerator.generateMetadataUrl(identifier: "foo") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/metadata/foo")
    } else {
      XCTFail("Error generating download URL")
    }
  }

}
