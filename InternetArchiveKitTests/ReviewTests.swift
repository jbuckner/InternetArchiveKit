//
//  ReviewTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/11/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON
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

  func testDecodesReviewerItemnameWithZippyJSON() throws {
    // Same decoder configuration as InternetArchive.swift
    let decoder = ZippyJSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let review = try decoder.decode(InternetArchive.Review.self, from: reviewJson)
    XCTAssertEqual(review.reviewer, "HughMcQToo")
    XCTAssertEqual(review.stars?.value, 5)
    XCTAssertEqual(review.reviewerItemname, "@hughmcqtoo")
  }

  func testDecodesReviewerItemnameWithFoundationJSONDecoder() throws {
    // ZippyJSONDecoder falls back to Foundation's JSONDecoder on unsupported
    // platforms, so both decoders must agree.
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let review = try decoder.decode(InternetArchive.Review.self, from: reviewJson)
    XCTAssertEqual(review.reviewer, "HughMcQToo")
    XCTAssertEqual(review.stars?.value, 5)
    XCTAssertEqual(review.reviewerItemname, "@hughmcqtoo")
  }

}
