//
//  InternetArchive+Reviews.swift
//  InternetArchiveKit
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation
import ZippyJSON

/// Reads the reviews on an item.
///
/// This is its own protocol so adding it doesn't change what mocks of
/// `InternetArchiveProtocol` or `InternetArchiveDecoding` have to implement.
public protocol InternetArchiveReviewing: Sendable {
  /// Fetches `/metadata/<identifier>/reviews`. An item with no reviews gives
  /// an empty array. An unknown identifier throws
  /// `InternetArchiveError.apiError` with the message archive.org sends back.
  func reviews(identifier: String) async throws -> [InternetArchive.Review]
}

extension InternetArchive: InternetArchiveReviewing {
  public func reviews(identifier: String) async throws -> [Review] {
    guard
      let url = urlGenerator.generateMetadataUrl(identifier: identifier)?
        .appendingPathComponent("reviews")
    else {
      throw InternetArchiveError.invalidUrl
    }
    // `Review` names its properties in camelCase, so keys like
    // `reviewer_itemname` need the snake-case conversion
    let decoder = ZippyJSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let envelope: ReviewsEnvelope = try await makeRequest(url: url, decoder: decoder).get()
    return envelope.result
  }
}

private struct ReviewsEnvelope: Decodable, Sendable {
  let result: [InternetArchive.Review]
}
