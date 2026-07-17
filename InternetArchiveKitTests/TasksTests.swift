//
//  TasksTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class TasksTests: XCTestCase {

  private let credentials = InternetArchive.Credentials(
    accessKey: "accessfoo", secretKey: "secretbar")

  func testGenerateTasksUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateTasksUrl(queryItems: [
        URLQueryItem(name: "identifier", value: "foo")
      ])?.absoluteString,
      "https://archive.org/services/tasks.php?identifier=foo"
    )
  }

  func testTasksRequiresCredentials() async {
    let archive = InternetArchive(
      urlGenerator: InternetArchive.URLGenerator(),
      urlSession: URLSession.mock
    )
    let result = await archive.tasks(identifier: "foo")
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

  func testTasksDecodesListing() async {
    let json = """
      {
        "success": true,
        "value": {
          "summary": {"queued": 1, "running": 0, "error": 0, "paused": 0},
          "catalog": [
            {"task_id": 111, "identifier": "foo", "cmd": "derive.php", "submitter": "bar@example.com", "priority": 0}
          ],
          "history": [
            {"task_id": 110, "identifier": "foo", "cmd": "archive.php", "submittime": "2026-07-16 10:00:00"}
          ],
          "cursor": "c:123456"
        }
      }
    """
    let urlGenerator = InternetArchive.URLGenerator()
    let queryItems: [URLQueryItem] = [
      URLQueryItem(name: "summary", value: "1"),
      URLQueryItem(name: "catalog", value: "1"),
      URLQueryItem(name: "history", value: "1"),
      URLQueryItem(name: "identifier", value: "foo"),
    ]
    guard let url = urlGenerator.generateTasksUrl(queryItems: queryItems) else {
      XCTFail("error generating tasks url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(json.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: credentials
    )
    let result = await archive.tasks(identifier: "foo")

    switch result {
    case .success(let listing):
      XCTAssertEqual(listing.summary?.queued, 1)
      XCTAssertEqual(listing.catalog?.first?.taskId, 111)
      XCTAssertEqual(listing.catalog?.first?.cmd, "derive.php")
      XCTAssertEqual(listing.history?.first?.taskId, 110)
      XCTAssertEqual(listing.cursor, "c:123456")
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }

    XCTAssertEqual(
      endpoint.requests.first?.value(forHTTPHeaderField: "Authorization"),
      "LOW accessfoo:secretbar"
    )
  }

  func testSubmitTaskSuccess() async {
    let json = """
      {"success": true, "value": {"task_id": 1234567, "log": "https://catalogd.archive.org/log/1234567"}}
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateTasksUrl(queryItems: []) else {
      XCTFail("error generating tasks url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(json.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: credentials
    )
    let result = await archive.submitTask(identifier: "foo", cmd: "derive.php")

    switch result {
    case .success(let submission):
      XCTAssertEqual(submission.taskId, 1234567)
      XCTAssertEqual(submission.log, "https://catalogd.archive.org/log/1234567")
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }

    let request = endpoint.requests.first
    XCTAssertEqual(request?.httpMethod, "POST")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
  }

  func testSubmitTaskFailureSurfacesError() async {
    let json = """
      {"success": false, "error": "not allowed to submit derive.php"}
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateTasksUrl(queryItems: []) else {
      XCTFail("error generating tasks url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(json.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: credentials
    )
    let result = await archive.submitTask(identifier: "foo", cmd: "derive.php")

    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(
          message: "not allowed to submit derive.php")
      )
    }
  }
}
