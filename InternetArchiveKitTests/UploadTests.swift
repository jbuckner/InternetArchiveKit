//
//  UploadTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class UploadTests: XCTestCase {

  private let credentials = InternetArchive.Credentials(
    accessKey: "accessfoo", secretKey: "secretbar")

  private func mockedArchive(
    itemIdentifier: String, fileName: String, status: Int, body: String
  ) -> (archive: InternetArchive, endpoint: BasicEndpointMock)? {
    let urlGenerator = InternetArchive.URLGenerator()
    guard
      let url = urlGenerator.generateUploadUrl(
        itemIdentifier: itemIdentifier, fileName: fileName)
    else { return nil }
    let endpoint = BasicEndpointMock(
      status: status, url: url, body: Data(body.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]
    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: credentials
    )
    return (archive, endpoint)
  }

  func testGenerateUploadUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateUploadUrl(
        itemIdentifier: "foo", fileName: "track1.mp3")?.absoluteString,
      "https://s3.us.archive.org/foo/track1.mp3"
    )
  }

  func testUploadRequiresCredentials() async {
    let archive = InternetArchive(
      urlGenerator: InternetArchive.URLGenerator(),
      urlSession: URLSession.mock
    )
    let result = await archive.upload(
      itemIdentifier: "foo", fileName: "track1.mp3", data: Data("abc".utf8))
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

  func testUploadSendsExpectedHeaders() async {
    guard
      let (archive, endpoint) = mockedArchive(
        itemIdentifier: "foo", fileName: "track1.mp3", status: 200, body: "")
    else {
      XCTFail("error generating upload url")
      return
    }

    let result = await archive.upload(
      itemIdentifier: "foo",
      fileName: "track1.mp3",
      data: Data("abc".utf8),
      contentType: "audio/mpeg",
      metadata: ["title": "Show ☃", "external_identifier": "xyz"],
      queueDerive: false,
      sizeHint: 12345
    )
    if case .failure(let error) = result {
      XCTFail("error, \(error.localizedDescription)")
    }

    let request = endpoint.requests.first
    XCTAssertEqual(request?.httpMethod, "PUT")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Authorization"),
      "LOW accessfoo:secretbar")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Content-Type"), "audio/mpeg")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "x-amz-auto-make-bucket"), "1")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "x-archive-queue-derive"), "0")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "x-archive-size-hint"), "12345")
    // non-ASCII metadata travels uri()-encoded
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "x-archive-meta-title"),
      "uri(Show%20%E2%98%83)")
    // underscores in metadata names travel as double hyphens
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "x-archive-meta-external--identifier"),
      "xyz")
  }

  func testUploadErrorSurfacesS3Message() async {
    let xml = """
      <?xml version='1.0' encoding='UTF-8'?>
      <Error><Code>AccessDenied</Code><Message>Access Denied</Message></Error>
    """
    guard
      let (archive, _) = mockedArchive(
        itemIdentifier: "foo", fileName: "track1.mp3", status: 403, body: xml)
    else {
      XCTFail("error generating upload url")
      return
    }

    let result = await archive.upload(
      itemIdentifier: "foo", fileName: "track1.mp3", data: Data("abc".utf8))

    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(message: "Access Denied")
      )
    }
  }

  func testDeleteFileSendsCascadeHeader() async {
    guard
      let (archive, endpoint) = mockedArchive(
        itemIdentifier: "foo", fileName: "track1.mp3", status: 204, body: "")
    else {
      XCTFail("error generating upload url")
      return
    }

    let result = await archive.deleteFile(
      itemIdentifier: "foo", fileName: "track1.mp3")
    if case .failure(let error) = result {
      XCTFail("error, \(error.localizedDescription)")
    }

    let request = endpoint.requests.first
    XCTAssertEqual(request?.httpMethod, "DELETE")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "x-archive-cascade-delete"), "1")
  }

  func testS3ErrorMessageExtraction() {
    XCTAssertEqual(
      InternetArchive.s3ErrorMessage(
        from: "<Error><Message>Bucket not found</Message></Error>"),
      "Bucket not found")
    XCTAssertNil(InternetArchive.s3ErrorMessage(from: "not xml"))
  }

  func testMetadataHeaderValueEncoding() {
    XCTAssertEqual(InternetArchive.metadataHeaderValue("plain ascii"), "plain ascii")
    XCTAssertEqual(
      InternetArchive.metadataHeaderValue("Show ☃"), "uri(Show%20%E2%98%83)")
  }
}
