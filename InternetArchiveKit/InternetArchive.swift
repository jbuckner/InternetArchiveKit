//
//  InternetArchive.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import ZippyJSON
import os.log

let logSubsystemId: String = "engineering.astral.internetarchivekit"

/// Interact with the InternetArchive API
///
/// ### Example Usage
/// ```
/// let query = InternetArchive.Query(
///   clauses: ["collection": "etree", "mediatype": "collection"])
/// let archive = InternetArchive()
///
/// let results = await archive.search(query: query, page: 0, rows: 10)
/// switch results {
/// case .success(let items):
///    // debugPrint(items)
/// case .failure(let error):
///    // debugPrint(error)
/// }
///
/// let result = await archive.itemDetail(identifier: "sci2007-07-28.Schoeps")
/// switch result {
/// case .success(let item):
///    // debugPrint(item)
/// case .failure(let error):
///    // debugPrint(error)
/// }
/// ```
public class InternetArchive: InternetArchiveProtocol {
  public convenience init() {
    let urlGenerator = URLGenerator()
    self.init(urlGenerator: urlGenerator, urlSession: URLSession.shared)
  }

  public init(
    urlGenerator: InternetArchiveURLGeneratorProtocol,
    urlSession: URLSession
  ) {
    self.urlGenerator = urlGenerator
    self.urlSession = urlSession
  }

  private let urlGenerator: InternetArchiveURLGeneratorProtocol

  private let jsonDecoder: ZippyJSONDecoder = {
    let decoder = ZippyJSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  /** @inheritdoc */
  public func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?
  ) async -> Result<SearchResponse, Error> {
    guard
      let searchUrl: URL = urlGenerator.generateSearchUrl(
        query: query,
        page: page,
        rows: rows,
        fields: fields ?? [],
        sortFields: sortFields ?? [],
        additionalQueryParams: []
      )
    else {
      os_log(
        .error,
        log: log,
        "Error generating search url: %@",
        query.asURLString ?? "Unknown query.asURLString"
      )
      return .failure(InternetArchiveError.invalidUrl)
    }

    return await makeRequest(url: searchUrl)
  }

  /** @inheritdoc */
  public func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]? = nil,
    sortFields: [InternetArchiveURLQueryItemProtocol]? = nil,
    completion: @escaping (InternetArchive.SearchResponse?, Error?) -> Void
  ) {
    Task {
      let results: Result<SearchResponse, Error> = await search(
        query: query,
        page: page,
        rows: rows,
        fields: fields,
        sortFields: sortFields
      )
      switch results {
      case .success(let response):
        completion(response, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  /** @inheritdoc */
  public func scrape(
    query: InternetArchiveURLStringProtocol,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    pagination: ScrapePagination?
  ) async -> Result<ScrapeResponse, Error> {
    guard
      let scrapeUrl: URL = urlGenerator.generateScrapeUrl(
        query: query,
        fields: fields ?? [],
        sortFields: sortFields ?? [],
        pagination: pagination,
        additionalQueryParams: []
      )
    else {
      os_log(
        .error,
        log: log,
        "Error generating scrape url: %@",
        query.asURLString ?? "Unknown query.asURLString"
      )
      return .failure(InternetArchiveError.invalidUrl)
    }

    return await makeRequest(url: scrapeUrl)
  }

  /** @inheritdoc */
  public func scrape(
    query: InternetArchiveURLStringProtocol,
    fields: [String]? = nil,
    sortFields: [InternetArchiveURLQueryItemProtocol]? = nil,
    pagination: ScrapePagination? = nil,
    completion: @escaping (InternetArchive.ScrapeResponse?, Error?) -> Void
  ) {
    Task {
      let results: Result<ScrapeResponse, Error> = await scrape(
        query: query,
        fields: fields,
        sortFields: sortFields,
        pagination: pagination
      )
      switch results {
      case .success(let response):
        completion(response, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  /** @inheritdoc */
  public func scrapeTotal(
    query: InternetArchiveURLStringProtocol
  ) async -> Result<Int, Error> {
    guard
      let scrapeUrl: URL = urlGenerator.generateScrapeUrl(
        query: query,
        fields: [],
        sortFields: [],
        pagination: nil,
        // `total_only=true` returns the match count with no items
        additionalQueryParams: [
          URLQueryItem(name: "total_only", value: "true")
        ]
      )
    else {
      os_log(
        .error,
        log: log,
        "Error generating scrapeTotal url: %@",
        query.asURLString ?? "Unknown query.asURLString"
      )
      return .failure(InternetArchiveError.invalidUrl)
    }

    let result: Result<ScrapeResponse, Error> = await makeRequest(url: scrapeUrl)
    return result.map { $0.total }
  }

  /** @inheritdoc */
  public func scrapeTotal(
    query: InternetArchiveURLStringProtocol,
    completion: @escaping (Int?, Error?) -> Void
  ) {
    Task {
      let result: Result<Int, Error> = await scrapeTotal(query: query)
      switch result {
      case .success(let total):
        completion(total, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  /** @inheritdoc */
  public func itemDetail(identifier: String) async -> Result<Item, Error> {
    guard
      let metadataUrl: URL = urlGenerator.generateMetadataUrl(
        identifier: identifier
      )
    else {
      os_log(
        .error,
        log: log,
        "itemDetail error generating metadata url, identifier: %{public}@",
        identifier
      )
      return .failure(InternetArchiveError.invalidUrl)
    }

    return await makeRequest(url: metadataUrl)
  }

  /** @inheritdoc */
  public func itemDetail(
    identifier: String,
    completion: @escaping (InternetArchive.Item?, Error?) -> Void
  ) {
    Task {
      let results: Result<Item, Error> = await itemDetail(
        identifier: identifier
      )
      switch results {
      case .success(let response):
        completion(response, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  private func makeRequest<T>(url: URL) async -> Result<T, Error>
  where T: Decodable {
    os_log(
      .info,
      log: log,
      "makeRequest start, url: %{public}@",
      url.absoluteString
    )
    let startTime: CFTimeInterval = CFAbsoluteTimeGetCurrent()

    do {
      let (data, _) = try await urlSession.data(from: url)
      let timeElapsed: CFTimeInterval = CFAbsoluteTimeGetCurrent() - startTime
      os_log(
        .info,
        log: log,
        "makeRequest completed in %{public}f s, url: %{public}@",
        timeElapsed,
        url.absoluteString
      )
      let results: T = try decodeResponse(data)
      return .success(results)
    } catch {
      os_log(
        .error,
        log: log,
        "makeRequest, error: %{public}@",
        error.localizedDescription
      )
      return .failure(error)
    }
  }

  /// Decode the expected payload. If that fails and the body is an
  /// HTTP-200 error envelope (`{"error": "…"}`), surface the API's
  /// message as `InternetArchiveError.apiError` instead of the
  /// shape-mismatch decoding error it would otherwise cause.
  private func decodeResponse<T>(_ data: Data) throws -> T
  where T: Decodable {
    do {
      return try jsonDecoder.decode(T.self, from: data)
    } catch {
      if let envelope = try? jsonDecoder.decode(
        APIErrorEnvelope.self, from: data
      ) {
        throw InternetArchiveError.apiError(message: envelope.error)
      }
      throw error
    }
  }

  private let urlSession: URLSession

  private let log: OSLog = OSLog(
    subsystem: logSubsystemId,
    category: "InternetArchive"
  )
}
