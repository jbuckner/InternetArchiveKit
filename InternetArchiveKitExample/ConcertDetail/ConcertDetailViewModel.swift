//
//  ConcertDetailViewModel.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import Observation

/// Loads a concert's metadata and resolves its audio files into playable tracks.
@MainActor
@Observable
final class ConcertDetailViewModel {
  private(set) var tracks: [Track] = []
  private(set) var venue: String?
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  @ObservationIgnored private let archive = InternetArchive()
  @ObservationIgnored private let urlGenerator = InternetArchive.URLGenerator()

  func load(identifier: String) async {
    isLoading = true
    errorMessage = nil
    let result = await archive.itemDetail(identifier: identifier)
    isLoading = false
    switch result {
    case .success(let item):
      venue = item.metadata?.venue?.value
      tracks = item.tracks(using: urlGenerator)
    case .failure(let error):
      tracks = []
      errorMessage = error.localizedDescription
    }
  }
}
