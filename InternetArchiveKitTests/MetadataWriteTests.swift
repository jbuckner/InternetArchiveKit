//
//  MetadataWriteTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class MetadataWriteTests: XCTestCase {

  private let credentials = InternetArchive.Credentials(
    accessKey: "accessfoo", secretKey: "secretbar")

  func testPatchOperationEncoding() throws {
    let patch: [InternetArchive.MetadataPatchOperation] = [
      .replace(path: "/venue", value: .string("Red Rocks")),
      .add(path: "/subject", value: .strings(["Live concert", "SBD"])),
      .remove(path: "/notes"),
    ]
    // key order within an operation is unordered JSON; sort for a stable comparison
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(patch)
    let json = String(decoding: data, as: UTF8.self)
    XCTAssertEqual(
      json,
      #"[{"op":"replace","path":"\/venue","value":"Red Rocks"},"#
        + #"{"op":"add","path":"\/subject","value":["Live concert","SBD"]},"#
        + #"{"op":"remove","path":"\/notes"}]"#
    )
  }

  func testModifyMetadataRequiresCredentials() async {
    let archive = InternetArchive(
      urlGenerator: InternetArchive.URLGenerator(),
      urlSession: URLSession.mock
    )
    let result = await archive.modifyMetadata(
      identifier: "foo", patch: [.remove(path: "/notes")])
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

  func testModifyMetadataSuccess() async {
    let json = """
      {"success": true, "task_id": 2391928033, "log": "https://catalogd.archive.org/log/2391928033"}
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateMetadataUrl(identifier: "foo") else {
      XCTFail("error generating metadata url")
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
    let result = await archive.modifyMetadata(
      identifier: "foo",
      patch: [.replace(path: "/venue", value: .string("Red Rocks"))]
    )

    switch result {
    case .success(let write):
      XCTAssertEqual(write.taskId, 2391928033)
      XCTAssertEqual(write.log, "https://catalogd.archive.org/log/2391928033")
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

  func testModifyMetadataFailureSurfacesError() async {
    let json = """
      {"success": false, "error": "no write access to this item"}
    """
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateMetadataUrl(identifier: "foo") else {
      XCTFail("error generating metadata url")
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
    let result = await archive.modifyMetadata(
      identifier: "foo", patch: [.remove(path: "/notes")])

    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(
          message: "no write access to this item")
      )
    }
  }
}
