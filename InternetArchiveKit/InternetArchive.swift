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
public final class InternetArchive: InternetArchiveProtocol, @unchecked Sendable {
  // Safe to share across concurrency domains: every stored property is a `let`
  // and requests run through the thread-safe `URLSession`. `@unchecked` is only
  // needed because the injected URL generator and JSON decoder aren't `Sendable`.
  public convenience init(credentials: Credentials? = nil) {
    let urlGenerator = URLGenerator()
    self.init(
      urlGenerator: urlGenerator,
      urlSession: URLSession.shared,
      credentials: credentials
    )
  }

  public init(
    urlGenerator: InternetArchiveURLGeneratorProtocol,
    urlSession: URLSession,
    credentials: Credentials? = nil
  ) {
    self.urlGenerator = urlGenerator
    self.urlSession = urlSession
    self.credentials = credentials
  }

  private let urlGenerator: InternetArchiveURLGeneratorProtocol
  private let credentials: Credentials?

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
    if URLGenerator.scrapeSortMisplacesIdentifier(sortFields ?? []) {
      return .failure(
        InternetArchiveError.invalidSortFields(
          message: "'identifier' must be the last sort field"
        )
      )
    }

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
  public func upload(
    itemIdentifier: String,
    fileName: String,
    data: Data,
    contentType: String? = nil,
    metadata: [String: String] = [:],
    autoMakeBucket: Bool = true,
    queueDerive: Bool = true,
    sizeHint: Int? = nil
  ) async -> Result<Void, Error> {
    guard credentials != nil else {
      return .failure(InternetArchiveError.missingCredentials)
    }
    guard
      let uploadUrl: URL = urlGenerator.generateUploadUrl(
        itemIdentifier: itemIdentifier,
        fileName: fileName
      )
    else {
      return .failure(InternetArchiveError.invalidUrl)
    }

    var request = authorizedRequest(url: uploadUrl)
    request.httpMethod = "PUT"
    request.httpBody = data
    if let contentType = contentType {
      request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    if autoMakeBucket {
      request.setValue("1", forHTTPHeaderField: "x-amz-auto-make-bucket")
    }
    if !queueDerive {
      request.setValue("0", forHTTPHeaderField: "x-archive-queue-derive")
    }
    if let sizeHint = sizeHint {
      request.setValue("\(sizeHint)", forHTTPHeaderField: "x-archive-size-hint")
    }
    for (key, value) in metadata {
      // IAS3 turns double hyphens back into underscores in metadata names
      let headerName = "x-archive-meta-"
        + key.replacingOccurrences(of: "_", with: "--")
      request.setValue(
        Self.metadataHeaderValue(value), forHTTPHeaderField: headerName)
    }

    return await performS3Request(request)
  }

  /** @inheritdoc */
  public func deleteFile(
    itemIdentifier: String,
    fileName: String,
    cascadeDerivatives: Bool = true
  ) async -> Result<Void, Error> {
    guard credentials != nil else {
      return .failure(InternetArchiveError.missingCredentials)
    }
    guard
      let uploadUrl: URL = urlGenerator.generateUploadUrl(
        itemIdentifier: itemIdentifier,
        fileName: fileName
      )
    else {
      return .failure(InternetArchiveError.invalidUrl)
    }

    var request = authorizedRequest(url: uploadUrl)
    request.httpMethod = "DELETE"
    if cascadeDerivatives {
      request.setValue("1", forHTTPHeaderField: "x-archive-cascade-delete")
    }

    return await performS3Request(request)
  }

  private func performS3Request(_ request: URLRequest) async -> Result<Void, Error> {
    do {
      let (data, response) = try await urlSession.data(for: request)
      if let httpResponse = response as? HTTPURLResponse,
        !(200..<300).contains(httpResponse.statusCode) {
        // IAS3 errors are S3-style XML with a Message element
        let body = String(decoding: data, as: UTF8.self)
        let message = Self.s3ErrorMessage(from: body)
          ?? "IAS3 request failed with HTTP \(httpResponse.statusCode)"
        return .failure(InternetArchiveError.apiError(message: message))
      }
      return .success(())
    } catch {
      return .failure(error)
    }
  }

  /// Extracts the Message element from an S3-style XML error body
  static func s3ErrorMessage(from body: String) -> String? {
    guard
      let start = body.range(of: "<Message>"),
      let end = body.range(of: "</Message>"),
      start.upperBound <= end.lowerBound
    else { return nil }
    return String(body[start.upperBound..<end.lowerBound])
  }

  /// IAS3 metadata header values with characters outside ASCII travel
  /// percent-encoded inside a `uri(...)` wrapper
  static func metadataHeaderValue(_ value: String) -> String {
    guard !value.allSatisfy({ $0.isASCII }) else { return value }
    var allowed = CharacterSet.alphanumerics
    allowed.insert(charactersIn: "-._~")
    let encoded = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    return "uri(\(encoded))"
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

  /** @inheritdoc */
  public func login(
    email: String,
    password: String
  ) async -> Result<Account, Error> {
    guard let loginUrl: URL = urlGenerator.generateXauthnUrl(operation: "login")
    else {
      return .failure(InternetArchiveError.invalidUrl)
    }

    // nothing in this method is logged: it handles the account password
    var request = URLRequest(url: loginUrl)
    request.httpMethod = "POST"
    request.setValue(
      "application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpBody = Self.formEncode([
      ("email", email),
      ("password", password),
    ])

    do {
      let (data, _) = try await urlSession.data(for: request)
      let envelope = try jsonDecoder.decode(XAuthnEnvelope.self, from: data)
      guard
        envelope.success,
        let values = envelope.values,
        let access = values.s3?.access,
        let secret = values.s3?.secret
      else {
        let reason = envelope.values?.reason ?? "login failed"
        return .failure(InternetArchiveError.apiError(message: reason))
      }
      let credentials = Credentials(
        accessKey: access,
        secretKey: secret,
        cookies: values.cookies ?? [:]
      )
      return .success(
        Account(credentials: credentials, screenname: values.screenname))
    } catch {
      return .failure(error)
    }
  }

  /// The request for `url` with the configured credentials attached, if any
  private func authorizedRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    if let credentials = credentials {
      request.setValue(
        credentials.authorizationHeaderValue, forHTTPHeaderField: "Authorization")
      if let cookieHeader = credentials.cookieHeaderValue {
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
      }
    }
    return request
  }

  /// Percent-encode fields into an `application/x-www-form-urlencoded` body
  static func formEncode(_ fields: [(String, String)]) -> Data? {
    var allowed = CharacterSet.alphanumerics
    allowed.insert(charactersIn: "-._~")
    return fields.compactMap { (key: String, value: String) -> String? in
      guard
        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed),
        let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed)
      else { return nil }
      return "\(encodedKey)=\(encodedValue)"
    }
    .joined(separator: "&")
    .data(using: .utf8)
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
      let (data, _) = try await urlSession.data(for: authorizedRequest(url: url))
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
