//
//  InternetArchive+Decoding.swift
//  InternetArchiveKit
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation
import ZippyJSON

/// One page of advancedsearch results decoded into the caller's own type.
public struct SearchResults<Doc: Decodable & Sendable>: Sendable {
  public let numFound: Int
  public let start: Int
  public let docs: [Doc]

  public init(numFound: Int, start: Int, docs: [Doc]) {
    self.numFound = numFound
    self.start = start
    self.docs = docs
  }
}

/// Fetches archive.org responses into types the caller defines, instead of
/// the full `Item` and `ItemMetadata` models.
///
/// The caller's types are decoded with default keys (no snake-case
/// conversion), so declare `CodingKeys` for any key that isn't a valid Swift
/// name, like `is_dark`. Use ``LenientValue`` for fields whose shape varies.
///
/// This is separate from `InternetArchiveProtocol` so adding it doesn't change
/// what existing mocks have to implement.
public protocol InternetArchiveDecoding: Sendable {
  func search<Doc: Decodable & Sendable>(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String],
    sortFields: [InternetArchiveURLQueryItemProtocol],
    documentType: Doc.Type
  ) async throws -> SearchResults<Doc>

  func metadata<Response: Decodable & Sendable>(
    identifier: String,
    as type: Response.Type
  ) async throws -> Response
}

extension InternetArchive: InternetArchiveDecoding {
  /// Runs an advancedsearch and decodes each doc as `Doc`. Builds the same URL
  /// and surfaces the same errors as `search(query:page:rows:fields:sortFields:)`.
  public func search<Doc: Decodable & Sendable>(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String] = [],
    sortFields: [InternetArchiveURLQueryItemProtocol] = [],
    documentType: Doc.Type
  ) async throws -> SearchResults<Doc> {
    guard
      let url = urlGenerator.generateSearchUrl(
        query: query,
        page: page,
        rows: rows,
        fields: fields,
        sortFields: sortFields,
        additionalQueryParams: []
      )
    else {
      throw InternetArchiveError.invalidUrl
    }
    let envelope: SearchEnvelope<Doc> = try await makeRequest(
      url: url, decoder: ZippyJSONDecoder()
    ).get()
    return SearchResults(
      numFound: envelope.response.numFound,
      start: envelope.response.start,
      docs: envelope.response.docs
    )
  }

  /// Fetches `/metadata/<identifier>` and decodes the whole response as
  /// `Response`. Surfaces the same errors as `itemDetail(identifier:)`.
  public func metadata<Response: Decodable & Sendable>(
    identifier: String,
    as type: Response.Type
  ) async throws -> Response {
    guard let url = urlGenerator.generateMetadataUrl(identifier: identifier) else {
      throw InternetArchiveError.invalidUrl
    }
    return try await makeRequest(url: url, decoder: ZippyJSONDecoder()).get()
  }
}

private struct SearchEnvelope<Doc: Decodable & Sendable>: Decodable, Sendable {
  struct Body: Decodable, Sendable {
    let numFound: Int
    let start: Int
    let docs: [Doc]
  }
  let response: Body
}
