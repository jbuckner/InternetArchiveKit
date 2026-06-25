//
//  ArtistsView.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import SwiftUI

/// Root screen: a searchable list of etree artists.
struct ArtistsView: View {
  @State private var viewModel = ArtistsViewModel()
  @State private var searchText = ""

  var body: some View {
    NavigationStack {
      List(viewModel.artists, id: \.identifier) { artist in
        NavigationLink(
          value: ArtistRoute(identifier: artist.identifier, title: artist.displayTitle)
        ) {
          Text(artist.displayTitle)
        }
      }
      .navigationTitle("Artists")
      .navigationDestination(for: ArtistRoute.self) { route in
        ConcertsView(artist: route)
      }
      .searchable(text: $searchText, prompt: "Search artists")
      .overlay { statusOverlay }
      .task(id: searchText) { await reloadArtists() }
    }
  }

  /// Debounces typing so each keystroke doesn't fire a request. Cancelling the
  /// previous task (when `searchText` changes) is what makes the debounce work;
  /// an empty field reloads instantly.
  private func reloadArtists() async {
    if !searchText.isEmpty {
      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled else { return }
    }
    await viewModel.search(matching: searchText)
  }

  @ViewBuilder
  private var statusOverlay: some View {
    if viewModel.isLoading && viewModel.artists.isEmpty {
      ProgressView()
    } else if let error = viewModel.errorMessage {
      ContentUnavailableView(
        "Couldn't Load Artists",
        systemImage: "wifi.slash",
        description: Text(error)
      )
    } else if viewModel.artists.isEmpty {
      if searchText.isEmpty {
        ContentUnavailableView("No Artists", systemImage: "music.mic")
      } else {
        ContentUnavailableView.search(text: searchText)
      }
    }
  }
}
