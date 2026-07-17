//
//  ReviewTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/11/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import InternetArchiveKit

class ReviewTests: XCTestCase {

  // Mirrors a review object from MockResponse/metadataResponse.json.
  // `reviewer_itemname` is the only snake_case key the API returns for a
  // review, so it only decodes through `.convertFromSnakeCase` if the Swift
  // property is named `reviewerItemname`.
  private let reviewJson = #"""
  {
    "reviewbody": "Stellar show. First set starts off with a nearly 14 minute Sugaree.",
    "reviewtitle": "This Matrix is deliciously ludicrous!",
    "reviewer": "HughMcQToo",
    "reviewer_itemname": "@hughmcqtoo",
    "reviewdate": "2017-12-11 18:56:28",
    "createdate": "2017-12-11 18:56:28",
    "stars": "5"
  }
  """#.data(using: .utf8)!

  func testDecodesReviewerItemname() throws {
    // Same decoder configuration as InternetArchive.swift
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let review = try decoder.decode(InternetArchive.Review.self, from: reviewJson)
    XCTAssertEqual(review.reviewer, "HughMcQToo")
    XCTAssertEqual(review.stars?.value, 5)
    XCTAssertEqual(review.reviewerItemname, "@hughmcqtoo")
  }

  // Deprecated context so the deprecated `reviewer_itemname` spellings can be
  // exercised without compiler warnings.
  @available(*, deprecated)
  func testDeprecatedSnakeCaseSpellingsStillWork() throws {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let review = try decoder.decode(InternetArchive.Review.self, from: reviewJson)
    XCTAssertEqual(review.reviewer_itemname, "@hughmcqtoo")

    let constructed = InternetArchive.Review(reviewer_itemname: "@someuser")
    XCTAssertEqual(constructed.reviewerItemname, "@someuser")
    XCTAssertEqual(constructed.reviewer_itemname, "@someuser")

    // Zero-argument and label-free calls must still resolve to the primary
    // init — guards against overload ambiguity.
    XCTAssertNil(InternetArchive.Review().reviewerItemname)
    XCTAssertNil(InternetArchive.Review(reviewer: "someuser").reviewerItemname)
  }

}
