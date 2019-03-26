//
//  InternetArchiveProtocols.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public protocol InternetArchiveProtocol {
  func search(query: InternetArchiveURLStringProtocol,
              page: Int,
              rows: Int,
              fields: [String]?,
              sortFields: [InternetArchiveURLQueryItemProtocol]?,
              completion: @escaping (InternetArchive.SearchResponse?, Error?) -> ())
  func itemDetail(identifier: String,
                  completion: @escaping (InternetArchive.Item?, Error?) -> ())
  func generateSearchUrl(query: InternetArchiveURLStringProtocol,
                         page: Int,
                         rows: Int,
                         fields: [String],
                         sortFields: [InternetArchiveURLQueryItemProtocol],
                         additionalQueryParams: [URLQueryItem]) -> URL?
  func generateMetadataUrl(identifier: String) -> URL?
  func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL?
}

public protocol InternetArchiveURLStringProtocol {
  var asURLString: String { get }
}

public protocol InternetArchiveURLQueryItemProtocol {
  var asQueryItem: URLQueryItem { get }
}

public protocol InternetArchiveQueryClauseProtocol: InternetArchiveURLStringProtocol {}
