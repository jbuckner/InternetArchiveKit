//
//  ReviewsEndpointTests.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest

@testable import InternetArchiveKit

/// `reviews(identifier:)` against bodies captured from
/// `archive.org/metadata/<id>/reviews`.
final class ReviewsEndpointTests: XCTestCase {

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

  func testDecodesReviewsFromTheResultEnvelope() async throws {
    let loader = StubLoader(
      body: """
        {"result":[
          {"review_id":"11345","reviewbody":"One of their best shows ever.\\n\\nMorning Dew.",
           "reviewtitle":"out of this world","reviewer":"soybomb",
           "reviewdate":"2004-04-09 16:57:46","createdate":"2004-04-09 16:57:46","stars":"5"},
          {"reviewtitle":"Great read","reviewbody":"Fun to read","stars":"0",
           "reviewer":"Neeraj Archive","reviewdate":"2026-07-21 16:54:50",
           "createdate":"2025-03-03 13:27:52","reviewer_itemname":"@neeraj_sharma341"}
        ]}
        """)
    let archive = InternetArchive(dataLoader: loader)

    let reviews = try await archive.reviews(identifier: "gd77-05-08")

    XCTAssertEqual(reviews.count, 2)
    XCTAssertEqual(reviews[0].reviewtitle, "out of this world")
    XCTAssertEqual(reviews[0].reviewer, "soybomb")
    XCTAssertEqual(reviews[0].stars?.value, 5)
    XCTAssertEqual(reviews[0].reviewbody?.value, "One of their best shows ever.\n\nMorning Dew.")
    XCTAssertNotNil(reviews[0].reviewdate?.value)
    // snake_case keys reach the camelCase property
    XCTAssertEqual(reviews[1].reviewerItemname, "@neeraj_sharma341")
    XCTAssertEqual(reviews[1].stars?.value, 0)
  }

  func testRequestsTheReviewsPath() async throws {
    let loader = StubLoader(body: #"{"result":[]}"#)
    let archive = InternetArchive(dataLoader: loader)

    _ = try await archive.reviews(identifier: "gd77-05-08")

    XCTAssertEqual(loader.requests.first?.url?.path, "/metadata/gd77-05-08/reviews")
  }

  func testNoReviewsIsAnEmptyArray() async throws {
    let archive = InternetArchive(dataLoader: StubLoader(body: #"{"result":[]}"#))
    let reviews = try await archive.reviews(identifier: "x")
    XCTAssertTrue(reviews.isEmpty)
  }

  /// The Archive sends `"reviewbody": []` for a review with no text.
  func testEmptyArrayReviewBodyDecodes() async throws {
    let archive = InternetArchive(
      dataLoader: StubLoader(
        body: """
          {"result":[{"reviewtitle":"Good-ish","reviewbody":[],"stars":"3",
          "reviewer":"NA_Mr_Seamus","reviewdate":"2025-06-02 19:44:10",
          "createdate":"2025-06-02 19:44:10","reviewer_itemname":"@mr_seamus_noad"}]}
          """))
    let reviews = try await archive.reviews(identifier: "x")
    XCTAssertEqual(reviews.count, 1)
    XCTAssertNil(reviews[0].reviewbody?.value)
    XCTAssertEqual(reviews[0].stars?.value, 3)
  }

  /// An unknown identifier is an HTTP 200 with an `error` body.
  func testUnknownIdentifierThrowsTheAPIMessage() async {
    let archive = InternetArchive(
      dataLoader: StubLoader(body: #"{"error":"Couldn't locate item 'nope'"}"#))
    do {
      _ = try await archive.reviews(identifier: "nope")
      XCTFail("expected an error")
    } catch InternetArchive.InternetArchiveError.apiError(let message) {
      XCTAssertEqual(message, "Couldn't locate item 'nope'")
    } catch {
      XCTFail("unexpected error \(error)")
    }
  }

  func testHTTPFailureThrows() async {
    let archive = InternetArchive(dataLoader: StubLoader(status: 503, body: "<html/>"))
    do {
      _ = try await archive.reviews(identifier: "x")
      XCTFail("expected an error")
    } catch InternetArchive.InternetArchiveError.httpError(let statusCode) {
      XCTAssertEqual(statusCode, 503)
    } catch {
      XCTFail("unexpected error \(error)")
    }
  }

  func testInternetArchiveIsReviewing() {
    let reviewing: any InternetArchiveReviewing = InternetArchive(
      dataLoader: StubLoader(body: "{}"))
    XCTAssertNotNil(reviewing)
  }
}
