//
//  ConcertsViewModel.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import Observation

/// Loads the concerts (recordings) belonging to an artist's collection.
@MainActor
@Observable
final class ConcertsViewModel {
  private(set) var concerts: [InternetArchive.ItemMetadata] = []
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  @ObservationIgnored private let archive = InternetArchive()

  func load(forArtistIdentifier identifier: String) async {
    isLoading = true
    errorMessage = nil
    let query = InternetArchive.Query(clauses: ["collection": identifier])
    let result = await archive.search(
      query: query,
      page: 0,
      rows: 100,
      fields: ["identifier", "title", "creator", "venue", "date"],
      sortFields: [InternetArchive.SortField(field: "date", direction: .desc)]
    )
    isLoading = false
    switch result {
    case .success(let response):
      concerts = response.response.docs
    case .failure(let error):
      concerts = []
      errorMessage = error.localizedDescription
    }
  }
}
