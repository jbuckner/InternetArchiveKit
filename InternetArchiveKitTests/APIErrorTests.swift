//
//  APIErrorTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/11/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

/// archive.org signals rejected searches (e.g. `q` over ~2,000 chars) as
/// HTTP 200 with an `{"error": "…"}` body and no `response` block. These
/// tests cover surfacing that envelope as `InternetArchiveError.apiError`
/// instead of a shape-mismatch `DecodingError`.
class APIErrorTests: XCTestCase {

  func testSearchErrorBodySurfacesAPIError() {
    let expectation = XCTestExpectation(description: "Search Error Body")
    let errorMessage =
      "[UNSUPPORTED_VALUE] The value specified in the request is not supported"
    let json = "{\"error\": \"\(errorMessage)\"}"
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let urlGenerator = InternetArchive.URLGenerator()
    let query: InternetArchive.Query = InternetArchive.Query(
      clauses: ["collection": "etree"])
    guard
      let url = urlGenerator.generateSearchUrl(
        query: query, page: 1, rows: 10, fields: [], sortFields: [],
        additionalQueryParams: [])
    else {
      XCTFail("error generating search url")
      return
    }

    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: data, headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    archive.search(query: query, page: 1, rows: 10) {
      (response: InternetArchive.SearchResponse?, error: Error?) in
      XCTAssertNil(response)
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(message: errorMessage)
      )
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }

  func testWrongShapeWithoutErrorKeyStaysDecodingError() {
    let expectation = XCTestExpectation(description: "Wrong Shape Body")
    // Valid JSON, wrong shape, no top-level "error" key — must NOT be
    // misclassified as an API error.
    let json = "{\"unexpected\": true}"
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let urlGenerator = InternetArchive.URLGenerator()
    let query: InternetArchive.Query = InternetArchive.Query(
      clauses: ["collection": "etree"])
    guard
      let url = urlGenerator.generateSearchUrl(
        query: query, page: 1, rows: 10, fields: [], sortFields: [],
        additionalQueryParams: [])
    else {
      XCTFail("error generating search url")
      return
    }

    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: data, headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    archive.search(query: query, page: 1, rows: 10) {
      (response: InternetArchive.SearchResponse?, error: Error?) in
      XCTAssertNil(response)
      XCTAssertNotNil(error)
      XCTAssertFalse(error is InternetArchive.InternetArchiveError)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }

  func testQueryLengthPredicate() {
    let max = InternetArchive.URLGenerator.recommendedMaxQueryLength
    XCTAssertFalse(
      InternetArchive.URLGenerator.queryExceedsRecommendedLength(nil))
    XCTAssertFalse(
      InternetArchive.URLGenerator.queryExceedsRecommendedLength(
        String(repeating: "a", count: max)))
    XCTAssertTrue(
      InternetArchive.URLGenerator.queryExceedsRecommendedLength(
        String(repeating: "a", count: max + 1)))
  }

  func testAPIErrorLocalizedDescription() {
    let error = InternetArchive.InternetArchiveError.apiError(
      message: "[UNSUPPORTED_VALUE] something")
    XCTAssertEqual(
      error.errorDescription,
      "Internet Archive API error: [UNSUPPORTED_VALUE] something"
    )
  }
}
