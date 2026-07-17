//
//  SimpleListsTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class SimpleListsTests: XCTestCase {

  func testGenerateSimpleListsUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateSimpleListsUrl(identifier: "foo")?.absoluteString,
      "https://archive.org/metadata/foo/simplelists"
    )
  }

  // list names and parent identifiers can contain underscores, so simple
  // lists responses decode without the snake-case key strategy
  func testSimpleListsDecodingPreservesKeys() async {
    let json: String = """
      {
        "result": {
          "holdings": {
            "library_of_atlantis": {
              "notes": {"isbn": ["123"]},
              "sys_changed_by": {"source": "mdapi"},
              "sys_last_changed": "2020-04-14 08:27:01.453137"
            }
          }
        }
      }
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateSimpleListsUrl(identifier: "child_item") else {
      XCTFail("error generating simple lists url")
      return
    }

    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: data, headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    let result = await archive.simpleLists(identifier: "child_item")

    switch result {
    case .success(let response):
      let membership = response.result["holdings"]?["library_of_atlantis"]
      XCTAssertNotNil(membership)
      XCTAssertEqual(membership?.sysLastChanged, "2020-04-14 08:27:01.453137")
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }
  }

  func testSimpleListsLive() async throws {
    // the example item from archive.org's simple lists docs
    let response: InternetArchive.SimpleListsResponse =
      try await InternetArchive().simpleLists(identifier: "isbn_9780920303122")
    XCTAssertNotNil(response.result["holdings"])
  }

  func testSimpleListsItemWithoutListsSurfacesApiError() async {
    let json: String = """
      {"error": "Couldn't get 'simplelists' for item foo"}
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateSimpleListsUrl(identifier: "foo") else {
      XCTFail("error generating simple lists url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: data, headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    let result = await archive.simpleLists(identifier: "foo")

    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(
          message: "Couldn't get 'simplelists' for item foo")
      )
    }
  }
}
