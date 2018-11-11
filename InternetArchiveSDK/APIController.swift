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
    private let host: String
    private let scheme: String

    public init(host: String = "archive.org", scheme: String = "https") {
      self.host = host
      self.scheme = scheme
    }

    public func generateSearchUrl(query: String, fields: [String], start: Int, rows: Int) -> URL? {
      let fieldParams: [URLQueryItem] = fields.compactMap { URLQueryItem(name: "fl[]", value: $0) }
      let params: [URLQueryItem] = fieldParams + [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "output", value: "json"),
        URLQueryItem(name: "rows", value: "\(rows)"),
        URLQueryItem(name: "start", value: "\(start)"),
      ]

      var urlComponents = URLComponents()
      urlComponents.scheme = self.scheme
      urlComponents.host = self.host
      urlComponents.path = "/advancedsearch.php"
      urlComponents.queryItems = params

      return urlComponents.url
    }

    public func generateMetadataUrl(identifier: String) -> URL? {
      var urlComponents = URLComponents()
      urlComponents.scheme = self.scheme
      urlComponents.host = self.host
      urlComponents.path = "/metadata/\(identifier)"
      return urlComponents.url
    }
  }
}
