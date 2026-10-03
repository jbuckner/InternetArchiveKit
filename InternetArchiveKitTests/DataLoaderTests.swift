//
//  DataLoaderTests.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

/// `InternetArchive` fetches through any `InternetArchiveDataLoading`.
final class DataLoaderTests: XCTestCase {

  private final class StubLoader: InternetArchiveDataLoading, @unchecked Sendable {
    let status: Int
    let body: Data
    private(set) var requests: [URLRequest] = []

    init(status: Int = 200, body: String) {
      self.status = status
      self.body = Data(body.utf8)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      requests.append(request)
      let url = request.url ?? URL(fileURLWithPath: "/")
      let response = HTTPURLResponse(
        url: url, statusCode: status, httpVersion: nil, headerFields: nil)
      return (body, response ?? URLResponse())
    }
  }

  private let searchJSON = """
    {"responseHeader":{"status":0,"QTime":1,"params":{"query":"x","qin":"x","fields":"identifier","wt":"json","rows":"1","start":0}},
     "response":{"numFound":1,"start":0,"docs":[{"identifier":"abc"}]}}
    """

  func testSearchUsesInjectedLoader() async throws {
    let loader = StubLoader(body: searchJSON)
    let archive = InternetArchive(dataLoader: loader)
    let query = InternetArchive.Query(clauses: ["collection": "etree"])

    let response: InternetArchive.SearchResponse = try await archive.search(
      query: query, page: 1, rows: 1)

    XCTAssertEqual(response.response.numFound, 1)
    XCTAssertEqual(response.response.docs.first?.identifier, "abc")
    XCTAssertEqual(loader.requests.count, 1)
    XCTAssertEqual(loader.requests.first?.url?.host, "archive.org")
    XCTAssertEqual(loader.requests.first?.httpMethod, "GET")
  }

  func testItemDetailRequestsMetadataUrl() async throws {
    let loader = StubLoader(body: "{\"metadata\":{\"identifier\":\"abc\"},\"files\":[]}")
    let archive = InternetArchive(
      urlGenerator: InternetArchive.URLGenerator(), dataLoader: loader)

    let item: InternetArchive.Item = try await archive.itemDetail(identifier: "abc")

    XCTAssertEqual(item.metadata?.identifier, "abc")
    XCTAssertEqual(loader.requests.first?.url?.path, "/metadata/abc")
  }

  func testNon2xxSurfacesHttpError() async {
    let archive = InternetArchive(dataLoader: StubLoader(status: 503, body: "<html/>"))
    do {
      let _: InternetArchive.Item = try await archive.itemDetail(identifier: "abc")
      XCTFail("expected an error")
    } catch {
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        .httpError(statusCode: 503))
    }
  }

  func testURLSessionIsADataLoader() {
    let loader: InternetArchiveDataLoading = URLSession.shared
    XCTAssertNotNil(loader)
    // the existing initializer still takes a session
    _ = InternetArchive(urlGenerator: InternetArchive.URLGenerator(), urlSession: .shared)
    _ = InternetArchive()
  }
}
