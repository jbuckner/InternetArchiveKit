//
//  InternetArchive.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import os.log
import Foundation

let logSubsystemId: String = "engineering.astral.internetarchivekit"

public class InternetArchive: InternetArchiveProtocol {
  public convenience init() {
    self.init(host: "archive.org", scheme: "https", urlSession: URLSession.shared)
  }

  public init(host: String, scheme: String, urlSession: URLSession) {
    self.urlComponents.scheme = scheme
    self.urlComponents.host = host
    self.urlSession = urlSession
  }

  // hits the advancedsearch url,
  // eg https://archive.org/advancedsearch.php?q=collection:(etree)+AND+mediatype:(collection)&outpt=json
  public func search(query: InternetArchiveURLStringProtocol,
                     page: Int,
                     rows: Int,
                     fields: [String]? = nil,
                     sortFields: [InternetArchiveURLQueryItemProtocol]? = nil,
                     completion: @escaping (InternetArchive.SearchResponse?, Error?) -> ()) {

    guard let searchUrl: URL = self.generateSearchUrl(
      query: query, page: page, rows: rows, fields: fields ?? [], sortFields: sortFields ?? [], additionalQueryParams: [])
      else {
        os_log(.error, log: log, "search error generating metadata url: %{public}@", query.asURLString)
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: searchUrl, completion: completion)
  }

  // hits the metadata url for a particular item,
  // eg https://archive.org/metadata/ymsb2006-07-03.flac16
  public func itemDetail(identifier: String, completion: @escaping (InternetArchive.Item?, Error?) -> () ) {
    guard let metadataUrl: URL = self.generateMetadataUrl(identifier: identifier) else {
      os_log(.error, log: log, "itemDetail error generating metadata url, identifier: %{public}@", identifier)
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: metadataUrl, completion: completion)
  }

  public func generateSearchUrl(query: InternetArchiveURLStringProtocol,
                                page: Int,
                                rows: Int,
                                fields: [String],
                                sortFields: [InternetArchiveURLQueryItemProtocol],
                                additionalQueryParams: [URLQueryItem]) -> URL? {

    let fieldParams: [URLQueryItem] = fields.compactMap { URLQueryItem(name: "fl[]", value: $0) }
    let sortParams: [URLQueryItem] = sortFields.compactMap { $0.asQueryItem }
    let params: [URLQueryItem] = sortParams + fieldParams + additionalQueryParams + [
      URLQueryItem(name: "q", value: query.asURLString),
      URLQueryItem(name: "output", value: "json"),
      URLQueryItem(name: "rows", value: "\(rows)"),
      URLQueryItem(name: "page", value: "\(page)"),
    ]

    urlComponents.path = "/advancedsearch.php"
    urlComponents.queryItems = params
    return urlComponents.url
  }

  public func generateMetadataUrl(identifier: String) -> URL? {
    urlComponents.path = "/metadata/\(identifier)"
    return urlComponents.url
  }

  public func generateItemImageUrl(itemIdentifier: String) -> URL? {
    urlComponents.path = "/services/img/\(itemIdentifier)"
    return urlComponents.url
  }

  public func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL? {
    urlComponents.path = "/download/\(itemIdentifier)/\(fileName)"
    return urlComponents.url
  }

  private func makeRequest<T>(url: URL, completion: @escaping (T?, Error?) -> ()) where T: Decodable {
    os_log(.info, log: log, "makeRequest start, url: %{public}@", url.absoluteString)
    let startTime: CFTimeInterval = CFAbsoluteTimeGetCurrent()
    let task = urlSession.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
      let timeElapsed: CFTimeInterval = CFAbsoluteTimeGetCurrent() - startTime
      os_log(.info, log: self.log, "makeRequest completed in %{public}f s, url: %{public}@", timeElapsed, url.absoluteString)

      guard let data = data else {
        completion(nil, error)
        return
      }

      do {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let results: T = try decoder.decode(T.self, from: data)
        completion(results, error)
      } catch {
        os_log(.error, log: self.log, "makeRequest, errorDecoding: %{public}@", error.localizedDescription)
        completion(nil, error)
      }
    }

    task.resume()
  }

  private var urlComponents: URLComponents = URLComponents()
  private var urlSession: URLSession

  private let log: OSLog = OSLog(subsystem: logSubsystemId, category: "InternetArchive")
}
