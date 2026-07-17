//
//  HTTPStatusTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

/// Non-2xx responses surface as `InternetArchiveError.httpError` carrying the
/// status code, unless the body carries the API's `{"error": …}` envelope,
/// which is surfaced as `apiError` for its more useful message.
class HTTPStatusTests: XCTestCase {

  func test404SurfacesHttpError() {
    let expectation = XCTestExpectation(description: "404 Response")
    guard let data: Data = "<html>not found</html>".data(using: .utf8) else {
      XCTFail("error encoding body to data")
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
      status: 404, url: url, body: data, headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    archive.search(query: query, page: 1, rows: 10) {
      (response: InternetArchive.SearchResponse?, error: Error?) in
      XCTAssertNil(response)
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.httpError(statusCode: 404)
      )
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }

  func testNon2xxWithErrorEnvelopeStaysApiError() {
    let expectation = XCTestExpectation(description: "400 With Envelope")
    let errorMessage = "[BAD_REQUEST] The request could not be understood"
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
      status: 400, url: url, body: data, headers: nil, error: nil)
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

  func testHttpErrorLocalizedDescription() {
    let error = InternetArchive.InternetArchiveError.httpError(statusCode: 503)
    XCTAssertEqual(error.errorDescription, "HTTP error 503")
  }
}
