//
//  ConcertDetailView.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import SwiftUI

/// Shows a concert's tracks and drives playback through the shared ``AudioPlayer``.
struct ConcertDetailView: View {
  let concert: ConcertRoute
  @State private var viewModel = ConcertDetailViewModel()
  @Environment(AudioPlayer.self) private var player

  var body: some View {
    List {
      ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
        Button {
          player.setQueue(viewModel.tracks)
          player.play(at: index)
        } label: {
          trackRow(track)
        }
        .buttonStyle(.plain)
      }
    }
    .navigationTitle(viewModel.venue ?? concert.title)
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom) { PlayerBar() }
    .overlay { statusOverlay }
    .task { await viewModel.load(identifier: concert.identifier) }
  }

  private func trackRow(_ track: Track) -> some View {
    HStack(spacing: 12) {
      leadingIcon(for: track)
        .frame(width: 18)
      Text(track.title)
        .lineLimit(1)
      Spacer()
    }
    .contentShape(Rectangle())
  }

  @ViewBuilder
  private func leadingIcon(for track: Track) -> some View {
    if player.currentTrack?.id == track.id {
      Image(systemName: player.isPlaying ? "speaker.wave.2.fill" : "pause.fill")
        .foregroundStyle(.tint)
    } else if let number = track.trackNumber {
      Text("\(number)")
        .font(.callout.monospacedDigit())
        .foregroundStyle(.secondary)
    } else {
      Image(systemName: "music.note")
        .foregroundStyle(.secondary)
    }
  }

  @ViewBuilder
  private var statusOverlay: some View {
    if viewModel.isLoading {
      ProgressView()
    } else if let error = viewModel.errorMessage {
      ContentUnavailableView(
        "Couldn't Load Concert",
        systemImage: "wifi.slash",
        description: Text(error)
      )
    } else if viewModel.tracks.isEmpty {
      ContentUnavailableView("No Tracks", systemImage: "music.note")
    }
  }
}
