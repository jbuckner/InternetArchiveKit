//
//  ChangesTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class ChangesTests: XCTestCase {

  func testGenerateChangesUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateChangesUrl()?.absoluteString,
      "https://be-api.us.archive.org/changes/v1"
    )
  }

  func testChangesRequiresCredentials() async {
    let archive = InternetArchive(
      urlGenerator: InternetArchive.URLGenerator(),
      urlSession: URLSession.mock
    )
    let result = await archive.changes()
    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.missingCredentials
      )
    }
  }

  func testChangesDecodesBatch() async {
    let json = """
      {
        "changes": [{"identifier": "foo"}, {"identifier": "bar_baz"}],
        "next_token": "tok123",
        "estimated_distance_from_head": 5,
        "do_sleep_before_returning": false
      }
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateChangesUrl() else {
      XCTFail("error generating changes url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(json.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: InternetArchive.Credentials(
        accessKey: "accessfoo", secretKey: "secretbar")
    )
    let result = await archive.changes(start: .coldStart)

    switch result {
    case .success(let response):
      XCTAssertEqual(response.changes.map { $0.identifier }, ["foo", "bar_baz"])
      XCTAssertEqual(response.nextToken, "tok123")
      XCTAssertEqual(response.estimatedDistanceFromHead, 5)
      XCTAssertEqual(response.doSleepBeforeReturning, false)
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }

    let request = endpoint.requests.first
    XCTAssertEqual(request?.httpMethod, "POST")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Content-Type"),
      "application/x-www-form-urlencoded"
    )
  }
}
