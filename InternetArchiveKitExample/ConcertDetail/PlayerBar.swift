//
//  PlayerBar.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/14/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import SwiftUI

/// A compact transport bar pinned beneath the track list while a track is loaded.
struct PlayerBar: View {
  @Environment(AudioPlayer.self) private var player

  var body: some View {
    if let track = player.currentTrack {
      HStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 2) {
          Text(track.title)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
          Text("Now Playing")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Button { player.previous() } label: {
          Image(systemName: "backward.fill")
        }
        Button { player.togglePlayPause() } label: {
          Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
            .frame(width: 24)
        }
        Button { player.next() } label: {
          Image(systemName: "forward.fill")
        }
      }
      .font(.title3)
      .padding(.horizontal)
      .padding(.vertical, 10)
      .background(.ultraThinMaterial)
    }
  }
}
