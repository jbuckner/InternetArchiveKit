//
//  InternetArchiveProtocols.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

/// A protocol to which the main `InternetArchive` class conforms
public protocol InternetArchiveProtocol {
  /**
   Search the Internet Archive
  
   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - page: The results pagination page number
   - rows: The number of results to return per page
   - fields: An array of strings specifying the metadata entries you want returned. The default is `nil`,
   which return all metadata fields
   - sortFields: The fields by which you want to sort the results as an `InternetArchiveURLQueryItemProtocol` object
   - returns: Result<InternetArchive.SearchResponse, Error>
   */
  func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?
  ) async throws -> InternetArchive.SearchResponse

  /**
   Search the Internet Archive
  
   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - page: The results pagination page number
   - rows: The number of results to return per page
   - fields: An array of strings specifying the metadata entries you want returned. The default is `nil`,
   which return all metadata fields
   - sortFields: The fields by which you want to sort the results as an `InternetArchiveURLQueryItemProtocol` object
   - returns: Result<InternetArchive.SearchResponse, Error>
   */
  func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?
  ) async -> Result<InternetArchive.SearchResponse, Error>

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
  func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    completion: @escaping (InternetArchive.SearchResponse?, Error?) -> Void
  )

  /**
   Fetch a single item from the Internet Archive
  
   - parameters:
   - identifier: The item identifier
   - returns: Result<InternetArchive.Item, Error>
   */
  func itemDetail(
    identifier: String
  ) async throws -> InternetArchive.Item

  /**
   Fetch a single item from the Internet Archive
  
   - parameters:
   - identifier: The item identifier
   - returns: Result<InternetArchive.Item, Error>
   */
  func itemDetail(
    identifier: String
  ) async -> Result<InternetArchive.Item, Error>

  /**
   Fetch a single item from the Internet Archive
  
   - parameters:
   - identifier: The item identifier
   - completion: Returns optional `InternetArchive.Item` and `Error` objects
   - returns: No value
   */
  func itemDetail(
    identifier: String,
    completion: @escaping (InternetArchive.Item?, Error?) -> Void
  )
}

/// A protocol to which the main `InternetArchive.URLGenerator` class conforms
public protocol InternetArchiveURLGeneratorProtocol {
  func generateItemImageUrl(itemIdentifier: String) -> URL?
  func generateMetadataUrl(identifier: String) -> URL?
  func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL?
  func generateSearchUrl(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String],
    sortFields: [InternetArchiveURLQueryItemProtocol],
    additionalQueryParams: [URLQueryItem]
  ) -> URL?
}

/// A protocol for abstracting URL search query strings
///
/// All of the search queries components like Query and DateQuery conform to this
public protocol InternetArchiveURLStringProtocol {
  var asURLString: String? { get }
}

/// A protocol for abstracting URL query items for a search
public protocol InternetArchiveURLQueryItemProtocol {
  var asQueryItem: URLQueryItem { get }
}

extension InternetArchiveProtocol {
  /** @inheritdoc */
  public func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?
  ) async throws -> InternetArchive.SearchResponse {
    let result: Result<InternetArchive.SearchResponse, Error> = await search(
      query: query,
      page: page,
      rows: rows,
      fields: fields,
      sortFields: sortFields
    )

    switch result {
    case .success(let success):
      return success
    case .failure(let error):
      throw error
    }
  }

  /** @inheritdoc */
  public func itemDetail(identifier: String) async throws
    -> InternetArchive.Item
  {
    let result: Result<InternetArchive.Item, Error> = await itemDetail(
      identifier: identifier
    )
    switch result {
    case .success(let success):
      return success
    case .failure(let failure):
      throw failure
    }
  }
}
