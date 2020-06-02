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
  public func search(query: InternetArchiveURLStringProtocol,
                     page: Int,
                     rows: Int,
                     fields: [String]? = nil,
                     sortFields: [InternetArchiveURLQueryItemProtocol]? = nil,
                     completion: @escaping (InternetArchive.SearchResponse?, Error?) -> Void) {

    guard let searchUrl: URL = self.urlGenerator.generateSearchUrl(
      query: query, page: page, rows: rows, fields: fields ?? [], sortFields: sortFields ?? [],
      additionalQueryParams: [])
      else {
        if #available(iOS 12.0, *) {
          os_log("search error generating metadata url: %{public}@", log: log, type: .error, query.asURLString)
        } else {
          NSLog("search error generating metadata url: %@", query.asURLString)
        }
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: searchUrl, completion: completion)
  }

  /**
   Fetch a single item from the Internet Archive

   - parameters:
     - identifier: The item identifier
     - completion: Returns optional `InternetArchive.Item` and `Error` objects

   - returns: No value
   */
  public func itemDetail(identifier: String, completion: @escaping (InternetArchive.Item?, Error?) -> Void) {
    guard let metadataUrl: URL = self.urlGenerator.generateMetadataUrl(identifier: identifier) else {
      if #available(iOS 12.0, *) {
        os_log("itemDetail error generating metadata url, identifier: %{public}@", log: log, type: .error, identifier)
      } else {
        NSLog("itemDetail error generating metadata url, identifier: %@", identifier)
      }
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: metadataUrl, completion: completion)
  }

  private func makeRequest<T>(url: URL, completion: @escaping (T?, Error?) -> Void) where T: Decodable {
    if #available(iOS 12.0, *) {
      os_log("makeRequest start, url: %{public}@", log: log, type: .info, url.absoluteString)
    } else {
      NSLog("makeRequest start, url: %@", url.absoluteString)
    }
    let startTime: CFTimeInterval = CFAbsoluteTimeGetCurrent()
    let task = urlSession.dataTask(with: url) {(data: Data?, _: URLResponse?, error: Error?) in
      let timeElapsed: CFTimeInterval = CFAbsoluteTimeGetCurrent() - startTime
      if #available(iOS 12.0, *) {
        os_log("makeRequest completed in %{public}f s, url: %{public}@",
               log: self.log, type: .info, timeElapsed, url.absoluteString)
      } else {
        NSLog("makeRequest completed in %f s, url: %@", timeElapsed, url.absoluteString)
      }

      guard error == nil else {
        completion(nil, error)
        return
      }

      guard let data = data else {
        completion(nil, InternetArchiveError.noDataReturned)
        return
      }

      do {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let results: T = try decoder.decode(T.self, from: data)
        completion(results, error)
      } catch {
        if #available(iOS 12.0, *) {
          os_log("makeRequest, errorDecoding: %{public}@",
                 log: self.log, type: .error, error.localizedDescription)
        } else {
          NSLog("makeRequest, errorDecoding: %@", error.localizedDescription)
        }
        completion(nil, error)
      }
    }

    task.resume()
  }

  private let urlSession: URLSession

  private let log: OSLog = OSLog(subsystem: logSubsystemId, category: "InternetArchive")
}
