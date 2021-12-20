//
//  InternetArchive.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import os.log
import Foundation
import ZippyJSON
import AsyncCompatibilityKit

let logSubsystemId: String = "engineering.astral.internetarchivekit"

/**
 Interact with the InternetArchive API

 ### Example Usage
 ```
 let query = InternetArchive.Query(
   clauses: ["collection": "etree", "mediatype": "collection"])
 let archive = InternetArchive()

 archive.search(
   query: query,
   page: 0,
   rows: 10,
   completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
   // handle response
 })

 archive.itemDetail(
   identifier: "sci2007-07-28.Schoeps",
   completion: { (item: InternetArchive.Item?, error: Error?) in
   // handle item
 })
 ```
 */
public class InternetArchive: InternetArchiveProtocol {
  public convenience init() {
    let urlGenerator = URLGenerator()
    self.init(urlGenerator: urlGenerator, urlSession: URLSession.shared)
  }

  public init(urlGenerator: InternetArchiveURLGeneratorProtocol, urlSession: URLSession) {
    self.urlGenerator = urlGenerator
    self.urlSession = urlSession
  }

  private let urlGenerator: InternetArchiveURLGeneratorProtocol

  private let jsonDecoder: ZippyJSONDecoder = {
    let decoder = ZippyJSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  public func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?
  ) async -> Result<SearchResponse, Error> {
    guard let searchUrl: URL = urlGenerator.generateSearchUrl(
      query: query, page: page, rows: rows, fields: fields ?? [], sortFields: sortFields ?? [],
      additionalQueryParams: [])
    else {
      os_log(.error, log: log, "Error generating search url: %@", query.asURLString ?? "Unknown query.asURLString")
      return .failure(InternetArchiveError.invalidUrl)
    }

    return await makeRequest(url: searchUrl)
  }

  /**
   Search the Internet Archive

   - parameters:
     - query: The search query as an `InternetArchiveURLStringProtocol` object
     - page: The results pagination page number
     - rows: The number of results to return per page
     - fields: An array of strings specifying the metadata entries you want returned. The default is `nil`,
               which return all metadata fields
     - sortFields: The fields by which you want to sort the results as an `InternetArchiveURLQueryItemProtocol` object
     - completion: Returns optional `InternetArchive.SearchResponse` and `Error` objects
   */
  public func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]? = nil,
    sortFields: [InternetArchiveURLQueryItemProtocol]? = nil,
    completion: @escaping (InternetArchive.SearchResponse?, Error?) -> Void
  ) {
    Task {
      let results = await search(query: query, page: page, rows: rows, fields: fields, sortFields: sortFields)
      switch results {
      case .success(let response):
        completion(response, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  public func itemDetail(identifier: String) async -> Result<Item, Error> {
    guard let metadataUrl: URL = urlGenerator.generateMetadataUrl(identifier: identifier) else {
      os_log(.error, log: log, "itemDetail error generating metadata url, identifier: %{public}@", identifier)
      return .failure(InternetArchiveError.invalidUrl)
    }

    return await makeRequest(url: metadataUrl)
  }

  /**
   Fetch a single item from the Internet Archive

   - parameters:
     - identifier: The item identifier
     - completion: Returns optional `InternetArchive.Item` and `Error` objects

   - returns: No value
   */
  public func itemDetail(identifier: String, completion: @escaping (InternetArchive.Item?, Error?) -> Void) {
    Task {
      let results = await itemDetail(identifier: identifier)
      switch results {
      case .success(let response):
        completion(response, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }

  private func makeRequest<T>(url: URL) async -> Result<T, Error> where T: Decodable {
    os_log(.info, log: log, "makeRequest start, url: %{public}@", url.absoluteString)
    let startTime: CFTimeInterval = CFAbsoluteTimeGetCurrent()

    do {
      let (data, _) = try await urlSession.data(from: url)
      let timeElapsed: CFTimeInterval = CFAbsoluteTimeGetCurrent() - startTime
      os_log(.info, log: log, "makeRequest completed in %{public}f s, url: %{public}@", timeElapsed, url.absoluteString)
      let results: T = try jsonDecoder.decode(T.self, from: data)
      return .success(results)
    } catch {
      os_log(.error, log: log, "makeRequest, error: %{public}@", error.localizedDescription)
      return .failure(error)
    }
  }

  private let urlSession: URLSession

  private let log: OSLog = OSLog(subsystem: logSubsystemId, category: "InternetArchive")
}
