//
//  InternetArchiveURLGenerators.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 4/17/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public class URLGenerator: InternetArchiveURLGeneratorProtocol {
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

    private let host: String
    private let scheme: String
  }
}
