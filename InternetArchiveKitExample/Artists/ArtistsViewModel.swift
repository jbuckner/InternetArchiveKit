//
//  ArtistsViewModel.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import Observation

/// Loads etree artists for the root list: the most popular collections by
/// default, or a creator search while the user is typing.
@MainActor
@Observable
final class ArtistsViewModel {
  private(set) var artists: [InternetArchive.ItemMetadata] = []
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  @ObservationIgnored private let archive = InternetArchive()

  /// Loads the most-downloaded etree collections, shown when search is empty.
  func loadPopular() async {
    let query = InternetArchive.Query(
      clauses: ["collection": "etree", "mediatype": "collection"]
    )
    await runSearch(
      query: query,
      rows: 25,
      sortFields: [InternetArchive.SortField(field: "downloads", direction: .desc)]
    )
  }

  /// Searches etree artists whose creator matches `text`, falling back to the
  /// popular list when `text` is empty.
  func search(matching text: String) async {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      await loadPopular()
      return
    }
    let query = InternetArchive.Query(
      clauses: [
        "collection": "etree",
        "mediatype": "collection",
        "creator": "*\(trimmed)*",
      ]
    )
    await runSearch(
      query: query,
      rows: 50,
      sortFields: [InternetArchive.SortField(field: "title", direction: .asc)]
    )
  }

  private func runSearch(
    query: InternetArchive.Query,
    rows: Int,
    sortFields: [InternetArchive.SortField]
  ) async {
    isLoading = true
    errorMessage = nil
    let result = await archive.search(
      query: query,
      page: 0,
      rows: rows,
      fields: ["identifier", "title"],
      sortFields: sortFields
    )
    isLoading = false
    switch result {
    case .success(let response):
      artists = response.response.docs
    case .failure(let error):
      artists = []
      errorMessage = error.localizedDescription
    }
  }
}
