//
//  APIController.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/7/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public class APIController {
    public init(host: String = "archive.org", scheme: String = "https") {
      urlComponents.scheme = scheme
      urlComponents.host = host
    }

    public func generateSearchUrl(query: String, fields: [String], start: Int, rows: Int) -> URL? {
      let fieldParams: [URLQueryItem] = fields.compactMap { URLQueryItem(name: "fl[]", value: $0) }
      let params: [URLQueryItem] = fieldParams + [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "output", value: "json"),
        URLQueryItem(name: "rows", value: "\(rows)"),
        URLQueryItem(name: "start", value: "\(start)"),
      ]

      urlComponents.path = "/advancedsearch.php"
      urlComponents.queryItems = params
      return urlComponents.url
    }

    public func generateMetadataUrl(identifier: String) -> URL? {
      urlComponents.path = "/metadata/\(identifier)"
      return urlComponents.url
    }

    public func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL? {
      urlComponents.path = "/download/\(itemIdentifier)/\(fileName)"
      return urlComponents.url
    }

    private var urlComponents: URLComponents = URLComponents()
  }
}
