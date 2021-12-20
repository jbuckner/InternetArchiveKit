//
//  InternetArchiveProtocols.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

/**
 A protocol to which the main `InternetArchive` class conforms
 */
public protocol InternetArchiveProtocol {
  // swiftlint:disable:next function_parameter_count
  func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?
  ) async -> Result<InternetArchive.SearchResponse, Error>

  // swiftlint:disable:next function_parameter_count
  func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    completion: @escaping (InternetArchive.SearchResponse?, Error?) -> Void
  )

  func itemDetail(
    identifier: String
  ) async -> Result<InternetArchive.Item, Error>

  func itemDetail(
    identifier: String,
    completion: @escaping (InternetArchive.Item?, Error?) -> Void
  )
}

/**
 A protocol to which the main `InternetArchive.URLGenerator` class conforms
 */
public protocol InternetArchiveURLGeneratorProtocol {
  func generateItemImageUrl(itemIdentifier: String) -> URL?
  func generateMetadataUrl(identifier: String) -> URL?
  func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL?
  // swiftlint:disable:next function_parameter_count
  func generateSearchUrl(query: InternetArchiveURLStringProtocol,
                         page: Int,
                         rows: Int,
                         fields: [String],
                         sortFields: [InternetArchiveURLQueryItemProtocol],
                         additionalQueryParams: [URLQueryItem]) -> URL?
}

/**
 A protocol for abstracting URL search query strings

 All of the search queries components like Query and DateQuery conform to this
 */
public protocol InternetArchiveURLStringProtocol {
  var asURLString: String? { get }
}

/**
 A protocol for abstracting URL query items for a search
 */
public protocol InternetArchiveURLQueryItemProtocol {
  var asQueryItem: URLQueryItem { get }
}
