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

    /**
     Generate a Scrape API (`/services/search/v1/scrape`) url.

     The Scrape API scrolls through an entire result set with a `cursor` instead
     of `page`/`rows`, so it can read past the 10,000-result ceiling that
     `generateSearchUrl` is bound by. `pagination` is `.cursor` to resume or
     `.count` to size a batch; archive.org ignores `cursor` when a `count` is
     also sent, so the two are modelled as one mutually-exclusive value. Pass
     `nil` for the first batch at the server default size (~5,000 items); the
     response drops its `cursor` on the final batch.

     - parameters:
       - query: The search query
       - fields: The metadata fields to return
       - sortFields: The fields to sort by. archive.org requires `identifier`,
         if sorted on, to be the last sort field, and caps custom-sorted paging
         at 10,000 results.
       - pagination: `.cursor` to resume a scroll, `.count` to size a one-shot
         or first batch, or `nil` for the default first batch
       - additionalQueryParams: Any extra query items to append

     - returns: Optional scrape `URL`
     */
    public func generateScrapeUrl(
      query: InternetArchiveURLStringProtocol,
      fields: [String],
      sortFields: [InternetArchiveURLQueryItemProtocol],
      pagination: InternetArchive.ScrapePagination?,
      additionalQueryParams: [URLQueryItem]
    ) -> URL? {
      warnIfQueryExceedsRecommendedLength(query.asURLString)

      var params: [URLQueryItem] = [
        URLQueryItem(name: "q", value: query.asURLString)
      ]

      // The Scrape API takes single comma-delimited `fields` and `sorts`
      // parameters rather than the repeated `fl[]`/`sort[]` items that
      // advancedsearch.php uses.
      if !fields.isEmpty {
        params.append(
          URLQueryItem(name: "fields", value: fields.joined(separator: ","))
        )
      }

      // `SortField.asQueryItem` already formats each value as
      // "<field> <direction>", so reuse those values and join them.
      let sortValues: [String] = sortFields.compactMap { $0.asQueryItem.value }
      if !sortValues.isEmpty {
        params.append(
          URLQueryItem(name: "sorts", value: sortValues.joined(separator: ","))
        )
      }

      // archive.org rejects `count` and `cursor` together, which is why
      // `ScrapePagination` makes them mutually exclusive.
      if let pagination = pagination {
        switch pagination {
        case .count(let count):
          params.append(URLQueryItem(name: "count", value: "\(count)"))
        case .cursor(let cursor):
          params.append(URLQueryItem(name: "cursor", value: cursor))
        }
      }

      params += additionalQueryParams

      var urlComponents: URLComponents = getBaseUrlComponents()
      urlComponents.path = "/services/search/v1/scrape"
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

    /// `true` when a scrape `sorts` lists `identifier` somewhere other than the
    /// final position. archive.org rejects that (`identifier`, if present, must
    /// be the last sort key); `identifier` alone or last is fine. Split out as a
    /// static predicate so it is testable without a request — `scrape()` turns a
    /// `true` here into `InternetArchiveError.invalidSortFields` before sending.
    static func scrapeSortMisplacesIdentifier(
      _ sortFields: [InternetArchiveURLQueryItemProtocol]
    ) -> Bool {
      // `SortField.asQueryItem` formats each value as "<field> <direction>", so
      // the field name is the value's first whitespace-delimited token.
      let fieldNames: [String] = sortFields.map {
        String($0.asQueryItem.value?.split(separator: " ").first ?? "")
      }
      guard let identifierIndex = fieldNames.firstIndex(of: "identifier") else {
        return false
      }
      return identifierIndex != fieldNames.count - 1
    }

    /// The request is still sent — the gateway's `{"error": …}` body comes
    /// back as `InternetArchiveError.apiError` — but an oversized query is
    /// almost certainly a batching bug, so fail loudly in development.
    private func warnIfQueryExceedsRecommendedLength(_ queryString: String?) {
      guard Self.queryExceedsRecommendedLength(queryString),
        let queryString = queryString
      else { return }
      os_log(
        .error,
        log: log,
        // os_log formats are StaticStrings and can't be split across lines
        "search query is %{public}d chars; archive.org rejects q over ~2,000. Chunk against URLGenerator.recommendedMaxQueryLength (%{public}d). Query prefix: %{public}@",
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
