//
//  ScrapeViewModel.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 6/24/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import Observation

/// Walks the entire `etree` collection with the Scrape API's cursor pagination,
/// which reads past the 10,000-result ceiling `search()` is bound by.
///
/// `scrapeTotal()` fetches the match count up front; `scrape()` then scrolls
/// forward batch by batch, feeding each response's cursor into the next call
/// until the cursor comes back `nil`.
@MainActor
@Observable
final class ScrapeViewModel {
  private(set) var collections: [InternetArchive.ItemMetadata] = []
  private(set) var total: Int?
  private(set) var isLoading = false
  private(set) var reachedEnd = false
  private(set) var errorMessage: String?

  @ObservationIgnored private let archive = InternetArchive()
  @ObservationIgnored private let query = InternetArchive.Query(
    clauses: ["collection": "etree", "mediatype": "collection"]
  )
  /// `nil` requests the first batch at the server default size; a `.cursor`
  /// resumes where the previous batch left off.
  @ObservationIgnored private var nextPage: InternetArchive.ScrapePagination?

  /// Resets, then walks the whole result set from the first batch to the last.
  func loadAll() async {
    collections = []
    total = nil
    nextPage = nil
    reachedEnd = false
    errorMessage = nil

    // The match count, fetched without pulling any items.
    if case .success(let count) = await archive.scrapeTotal(query: query) {
      total = count
    }

    isLoading = true
    while !reachedEnd {
      let result = await archive.scrape(
        query: query,
        fields: ["identifier", "title"],
        sortFields: nil,
        pagination: nextPage
      )
      switch result {
      case .success(let response):
        collections += response.items
        if let cursor = response.cursor {
          nextPage = .cursor(cursor)  // keep scrolling forward
        } else {
          reachedEnd = true  // a nil cursor signals the end of the result set
        }
      case .failure(let error):
        errorMessage = error.localizedDescription
        reachedEnd = true
      }
      if Task.isCancelled { break }
    }
    isLoading = false
  }
}
