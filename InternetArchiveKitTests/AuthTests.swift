//
//  AuthTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class AuthTests: XCTestCase {

  private func searchSetup(
    credentials: InternetArchive.Credentials?
  ) -> (archive: InternetArchive, endpoint: BasicEndpointMock, query: InternetArchive.Query)? {
    let urlGenerator = InternetArchive.URLGenerator()
    let query: InternetArchive.Query = InternetArchive.Query(
      clauses: ["collection": "etree"])
    guard
      let url = urlGenerator.generateSearchUrl(
        query: query, page: 1, rows: 10, fields: [], sortFields: [],
        additionalQueryParams: [])
    else { return nil }

    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data("{}".utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]
    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: credentials
    )
    return (archive, endpoint, query)
  }

  func testAuthorizationHeaderAttached() async {
    let credentials = InternetArchive.Credentials(
      accessKey: "accessfoo",
      secretKey: "secretbar",
      cookies: ["logged-in-user": "foo%40example.com", "logged-in-sig": "xyz"]
    )
    guard let (archive, endpoint, query) = searchSetup(credentials: credentials) else {
      XCTFail("error generating search url")
      return
    }

    _ = await archive.search(query: query, page: 1, rows: 10, fields: [], sortFields: [])

    let request = endpoint.requests.first
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Authorization"),
      "LOW accessfoo:secretbar"
    )
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Cookie"),
      "logged-in-sig=xyz; logged-in-user=foo%40example.com"
    )
  }

  func testNoAuthorizationHeaderWithoutCredentials() async {
    guard let (archive, endpoint, query) = searchSetup(credentials: nil) else {
      XCTFail("error generating search url")
      return
    }

    _ = await archive.search(query: query, page: 1, rows: 10, fields: [], sortFields: [])

    XCTAssertNil(endpoint.requests.first?.value(forHTTPHeaderField: "Authorization"))
    XCTAssertNil(endpoint.requests.first?.value(forHTTPHeaderField: "Cookie"))
  }

  func testGenerateXauthnUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateXauthnUrl(operation: "login")?.absoluteString,
      "https://archive.org/services/xauthn/?op=login"
    )
  }

  func testFormEncode() {
    let data = InternetArchive.formEncode([
      ("email", "foo+bar@example.com"),
      ("password", "p@ss word&=1"),
    ])
    XCTAssertEqual(
      data.flatMap { String(data: $0, encoding: .utf8) },
      "email=foo%2Bbar%40example.com&password=p%40ss%20word%26%3D1"
    )
  }

  func testLoginSuccess() async {
    let json = """
      {
        "success": true,
        "values": {
          "s3": {"access": "accessfoo", "secret": "secretbar"},
          "cookies": {"logged-in-user": "foo%40example.com", "logged-in-sig": "xyz"},
          "screenname": "foo"
        },
        "version": 1
      }
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateXauthnUrl(operation: "login") else {
      XCTFail("error generating xauthn url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(json.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    let result = await archive.login(email: "foo@example.com", password: "hunter2")

    switch result {
    case .success(let account):
      XCTAssertEqual(account.credentials.accessKey, "accessfoo")
      XCTAssertEqual(account.credentials.secretKey, "secretbar")
      XCTAssertEqual(account.credentials.cookies["logged-in-sig"], "xyz")
      XCTAssertEqual(account.screenname, "foo")
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

  func testLoginFailureSurfacesReason() async {
    let json = """
      {"success": false, "values": {"reason": "bad credentials"}, "version": 1}
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateXauthnUrl(operation: "login") else {
      XCTFail("error generating xauthn url")
      return
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(json.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    let result = await archive.login(email: "foo@example.com", password: "wrong")

    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(message: "bad credentials")
      )
    }
  }
}
