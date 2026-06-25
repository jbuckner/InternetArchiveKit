//
//  ConcertsView.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import SwiftUI

/// Lists the concerts (recordings) for an artist.
struct ConcertsView: View {
  let artist: ArtistRoute
  @State private var viewModel = ConcertsViewModel()

  var body: some View {
    List(viewModel.concerts, id: \.identifier) { concert in
      NavigationLink(
        value: ConcertRoute(identifier: concert.identifier, title: concert.displayVenue)
      ) {
        VStack(alignment: .leading, spacing: 2) {
          Text(concert.displayVenue)
          if let date = concert.displayDate {
            Text(date)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .navigationTitle(artist.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationDestination(for: ConcertRoute.self) { concert in
      ConcertDetailView(concert: concert)
    }
    .overlay { statusOverlay }
    .task { await viewModel.load(forArtistIdentifier: artist.identifier) }
  }

  @ViewBuilder
  private var statusOverlay: some View {
    if viewModel.isLoading {
      ProgressView()
    } else if let error = viewModel.errorMessage {
      ContentUnavailableView(
        "Couldn't Load Concerts",
        systemImage: "wifi.slash",
        description: Text(error)
      )
    } else if viewModel.concerts.isEmpty {
      ContentUnavailableView("No Concerts", systemImage: "music.note.list")
    }
  }
}
