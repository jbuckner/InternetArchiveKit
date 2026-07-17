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

   This is for interactive, paged queries. archive.org caps paged search at the
   10,000th result; to read an entire result set past that, use `scrape()`.

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
  @available(*, deprecated, message: "Use the async version instead")
  func search(
    query: InternetArchiveURLStringProtocol,
    page: Int,
    rows: Int,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    completion: @escaping (InternetArchive.SearchResponse?, Error?) -> Void
  )

  /**
   Scrape the Internet Archive

   The Scrape API walks through an entire result set with a `cursor`, so it can
   read past the 10,000-result ceiling that `search()` is bound by. Start with
   `pagination: nil` (or `.count(n)` to size the first batch), then pass
   `.cursor(response.cursor)` back in to fetch each next batch until the
   response's `cursor` comes back `nil`. archive.org fixes the cursor batch size
   server-side (~5,000 items).

   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - fields: An array of strings specifying the metadata entries you want returned. The default is `nil`,
   which returns all metadata fields
   - sortFields: The fields by which you want to sort the results. archive.org requires `identifier`, if sorted
   on, to be the last sort field, and caps custom-sorted paging at 10,000 results
   - pagination: `.cursor` to resume, `.count` to size a one-shot or first batch, or `nil` for the default first batch
   - returns: Result<InternetArchive.ScrapeResponse, Error>
   */
  func scrape(
    query: InternetArchiveURLStringProtocol,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    pagination: InternetArchive.ScrapePagination?
  ) async throws -> InternetArchive.ScrapeResponse

  /**
   Scrape the Internet Archive

   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - fields: An array of strings specifying the metadata entries you want returned. The default is `nil`,
   which returns all metadata fields
   - sortFields: The fields by which you want to sort the results. archive.org requires `identifier`, if sorted
   on, to be the last sort field, and caps custom-sorted paging at 10,000 results
   - pagination: `.cursor` to resume, `.count` to size a one-shot or first batch, or `nil` for the default first batch
   - returns: Result<InternetArchive.ScrapeResponse, Error>
   */
  func scrape(
    query: InternetArchiveURLStringProtocol,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    pagination: InternetArchive.ScrapePagination?
  ) async -> Result<InternetArchive.ScrapeResponse, Error>

  /**
   Scrape the Internet Archive

   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - fields: An array of strings specifying the metadata entries you want returned. The default is `nil`,
   which returns all metadata fields
   - sortFields: The fields by which you want to sort the results. archive.org requires `identifier`, if sorted
   on, to be the last sort field, and caps custom-sorted paging at 10,000 results
   - pagination: `.cursor` to resume, `.count` to size a one-shot or first batch, or `nil` for the default first batch
   - completion: Returns optional `InternetArchive.ScrapeResponse` and `Error` objects
   */
  @available(*, deprecated, message: "Use the async version instead")
  func scrape(
    query: InternetArchiveURLStringProtocol,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    pagination: InternetArchive.ScrapePagination?,
    completion: @escaping (InternetArchive.ScrapeResponse?, Error?) -> Void
  )

  /**
   Count the results of a Scrape API query

   Returns the total number of matching items without fetching any of them
   (the Scrape API's `total_only`). Cheaper than reading `total` off a regular
   `scrape()` batch, which also pulls down a batch of items.

   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - returns: Result<Int, Error>
   */
  func scrapeTotal(
    query: InternetArchiveURLStringProtocol
  ) async throws -> Int

  /**
   Count the results of a Scrape API query

   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - returns: Result<Int, Error>
   */
  func scrapeTotal(
    query: InternetArchiveURLStringProtocol
  ) async -> Result<Int, Error>

  /**
   Count the results of a Scrape API query

   - parameters:
   - query: The search query as an `InternetArchiveURLStringProtocol` object
   - completion: Returns an optional total count and `Error` object
   */
  @available(*, deprecated, message: "Use the async version instead")
  func scrapeTotal(
    query: InternetArchiveURLStringProtocol,
    completion: @escaping (Int?, Error?) -> Void
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
  @available(*, deprecated, message: "Use the async version instead")
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
  func generateScrapeUrl(
    query: InternetArchiveURLStringProtocol,
    fields: [String],
    sortFields: [InternetArchiveURLQueryItemProtocol],
    pagination: InternetArchive.ScrapePagination?,
    additionalQueryParams: [URLQueryItem]
  ) -> URL?
}

/// A protocol for abstracting URL search query strings
///
/// All of the search queries components like Query and DateQuery conform to this
public protocol InternetArchiveURLStringProtocol: Sendable {
  var asURLString: String? { get }
}

/// A protocol for abstracting URL query items for a search
public protocol InternetArchiveURLQueryItemProtocol: Sendable {
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
  public func scrape(
    query: InternetArchiveURLStringProtocol,
    fields: [String]?,
    sortFields: [InternetArchiveURLQueryItemProtocol]?,
    pagination: InternetArchive.ScrapePagination?
  ) async throws -> InternetArchive.ScrapeResponse {
    let result: Result<InternetArchive.ScrapeResponse, Error> = await scrape(
      query: query,
      fields: fields,
      sortFields: sortFields,
      pagination: pagination
    )

    switch result {
    case .success(let success):
      return success
    case .failure(let error):
      throw error
    }
  }

  /** @inheritdoc */
  public func scrapeTotal(
    query: InternetArchiveURLStringProtocol
  ) async throws -> Int {
    let result: Result<Int, Error> = await scrapeTotal(query: query)
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
