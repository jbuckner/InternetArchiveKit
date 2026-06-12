//
//  InternetArchiveURLGenerators.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 4/17/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import Foundation
import os.log

extension InternetArchive {
  public class URLGenerator: InternetArchiveURLGeneratorProtocol {
    /// archive.org's search gateway rejects `q` values somewhere above
    /// ~1,900–2,000 characters — HTTP 200 with an `{"error": "…"}` body
    /// (surfaced as `InternetArchiveError.apiError`). This budget leaves
    /// headroom below the measured limit; clients batching values into a
    /// single clause should chunk against it.
    public static let recommendedMaxQueryLength: Int = 1_800

    public init(host: String = "archive.org", scheme: String = "https") {
      self.host = host
      self.scheme = scheme
    }

    /**
     Generate the metadata url for an Internet Archive search
    
     - parameters:
     - identifier: The item identifier
    
     - returns: Optional metadata `URL`
     */
    public func generateMetadataUrl(identifier: String) -> URL? {
      var urlComponents: URLComponents = getBaseUrlComponents()
      urlComponents.path = "/metadata/\(identifier)"
      return urlComponents.url
    }

    /**
     Generate the item image url for an Internet Archive item
    
     - parameters:
     - itemIdentifier: The item identifier
    
     - returns: Optional item image `URL`
     */
    public func generateItemImageUrl(itemIdentifier: String) -> URL? {
      var urlComponents: URLComponents = getBaseUrlComponents()
      urlComponents.path = "/services/img/\(itemIdentifier)"
      return urlComponents.url
    }

    /**
     Generate the download url for an Internet Archive file
    
     - parameters:
     - itemIdentifier: The item identifier
     - fileName: The file name
    
     - returns: Optional file download `URL`
     */
    public func generateDownloadUrl(itemIdentifier: String, fileName: String)
      -> URL?
    {
      var urlComponents: URLComponents = getBaseUrlComponents()
      urlComponents.path = "/download/\(itemIdentifier)/\(fileName)"
      return urlComponents.url
    }

    public func generateSearchUrl(
      query: InternetArchiveURLStringProtocol,
      page: Int,
      rows: Int,
      fields: [String],
      sortFields: [InternetArchiveURLQueryItemProtocol],
      additionalQueryParams: [URLQueryItem]
    ) -> URL? {
      warnIfQueryExceedsRecommendedLength(query.asURLString)

      let fieldParams: [URLQueryItem] = fields.compactMap {
        URLQueryItem(name: "fl[]", value: $0)
      }
      let sortParams: [URLQueryItem] = sortFields.compactMap { $0.asQueryItem }
      let params: [URLQueryItem] =
        sortParams + fieldParams + additionalQueryParams + [
          URLQueryItem(name: "q", value: query.asURLString),
          URLQueryItem(name: "output", value: "json"),
          URLQueryItem(name: "rows", value: "\(rows)"),
          URLQueryItem(name: "page", value: "\(page)"),
        ]

      var urlComponents: URLComponents = getBaseUrlComponents()
      urlComponents.path = "/advancedsearch.php"
      urlComponents.queryItems = params
      return urlComponents.url
    }

    private func getBaseUrlComponents() -> URLComponents {
      var urlComponents: URLComponents = URLComponents()
      urlComponents.scheme = scheme
      urlComponents.host = host
      return urlComponents
    }

    /// `true` when the assembled `q` string is over
    /// `recommendedMaxQueryLength`. Split out from the warning so the
    /// predicate is testable without tripping `assertionFailure`.
    static func queryExceedsRecommendedLength(_ queryString: String?) -> Bool {
      (queryString?.count ?? 0) > recommendedMaxQueryLength
    }

    /// The request is still sent — the gateway's `{"error": …}` body comes
    /// back as `InternetArchiveError.apiError` — but an oversized query is
    /// almost certainly a batching bug, so fail loudly in development.
    private func warnIfQueryExceedsRecommendedLength(_ queryString: String?) {
      guard Self.queryExceedsRecommendedLength(queryString),
            let queryString = queryString else { return }
      os_log(
        .error,
        log: log,
        "search query is %d chars; archive.org rejects q over ~2,000. Chunk against URLGenerator.recommendedMaxQueryLength (%d). Query prefix: %{public}@",
        queryString.count,
        Self.recommendedMaxQueryLength,
        String(queryString.prefix(120))
      )
      assertionFailure(
        "archive.org search query is \(queryString.count) chars — over the "
          + "~2,000-char gateway limit. Chunk the query against "
          + "URLGenerator.recommendedMaxQueryLength."
      )
    }

    private let host: String
    private let scheme: String

    private let log: OSLog = OSLog(
      subsystem: logSubsystemId,
      category: "URLGenerator"
    )
  }
}
