//
//  ReviewWriteTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class ReviewWriteTests: XCTestCase {

  private let credentials = InternetArchive.Credentials(
    accessKey: "accessfoo", secretKey: "secretbar")

  private func mockedArchive(
    identifier: String, body: String
  ) -> (archive: InternetArchive, endpoint: BasicEndpointMock)? {
    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateReviewsUrl(identifier: identifier) else {
      return nil
    }
    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: Data(body.utf8), headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]
    let archive = InternetArchive(
      urlGenerator: urlGenerator,
      urlSession: URLSession.mock,
      credentials: credentials
    )
    return (archive, endpoint)
  }

  func testGenerateReviewsUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateReviewsUrl(identifier: "foo")?.absoluteString,
      "https://archive.org/services/reviews.php?identifier=foo"
    )
  }

  func testSubmitReviewRequiresCredentials() async {
    let archive = InternetArchive(
      urlGenerator: InternetArchive.URLGenerator(),
      urlSession: URLSession.mock
    )
    let result = await archive.submitReview(
      identifier: "foo", title: "Great show", body: "Stellar sound")
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

  func testSubmitReviewSuccess() async {
    let json = """
      {"success": true, "value": {"task_id": 1234, "review_updated": true}}
    """
    guard let (archive, endpoint) = mockedArchive(identifier: "foo", body: json) else {
      XCTFail("error generating reviews url")
      return
    }

    let result = await archive.submitReview(
      identifier: "foo", title: "Great show", body: "Stellar sound", stars: 5)

    switch result {
    case .success(let write):
      XCTAssertEqual(write.taskId, 1234)
      XCTAssertEqual(write.reviewUpdated, true)
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }

    let request = endpoint.requests.first
    XCTAssertEqual(request?.httpMethod, "POST")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(
      request?.value(forHTTPHeaderField: "Authorization"),
      "LOW accessfoo:secretbar"
    )
  }

  func testDeleteReviewSuccess() async {
    let json = """
      {"success": true, "value": {"task_id": 5678}}
    """
    guard let (archive, endpoint) = mockedArchive(identifier: "foo", body: json) else {
      XCTFail("error generating reviews url")
      return
    }

    let result = await archive.deleteReview(identifier: "foo")

    switch result {
    case .success(let write):
      XCTAssertEqual(write.taskId, 5678)
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }

    XCTAssertEqual(endpoint.requests.first?.httpMethod, "DELETE")
  }

  func testMyReviewSuccess() async {
    let json = """
      {
        "success": true,
        "value": {
          "reviewbody": "Stellar sound",
          "reviewtitle": "Great show",
          "reviewer": "foo",
          "reviewer_itemname": "@foo",
          "reviewdate": "2017-12-11 18:56:28",
          "createdate": "2017-12-11 18:56:28",
          "stars": "5"
        }
      }
    """
    guard let (archive, _) = mockedArchive(identifier: "foo", body: json) else {
      XCTFail("error generating reviews url")
      return
    }

    let result = await archive.myReview(identifier: "foo")

    switch result {
    case .success(let review):
      XCTAssertEqual(review.reviewtitle, "Great show")
      XCTAssertEqual(review.reviewerItemname, "@foo")
      XCTAssertEqual(review.stars?.value, 5)
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }
  }

  func testSubmitReviewFailureSurfacesError() async {
    let json = """
      {"success": false, "error": "item not found"}
    """
    guard let (archive, _) = mockedArchive(identifier: "foo", body: json) else {
      XCTFail("error generating reviews url")
      return
    }

    let result = await archive.submitReview(
      identifier: "foo", title: "x", body: "y")

    switch result {
    case .success:
      XCTFail("expected a failure")
    case .failure(let error):
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError,
        InternetArchive.InternetArchiveError.apiError(message: "item not found")
      )
    }
  }
}
