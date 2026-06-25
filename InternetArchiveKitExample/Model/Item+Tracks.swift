//
//  Item+Tracks.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import InternetArchiveKit

extension InternetArchive.Item {
  /// The item's audio files (`VBR MP3`) sorted by track number, then title.
  ///
  /// Track numbers are sometimes missing, so equal numbers fall back to a title
  /// comparison. Tapers occasionally prefix the track number onto the title,
  /// which makes that a reasonable tiebreaker.
  var sortedTracks: [InternetArchive.File] {
    (files ?? [])
      .filter { $0.format?.value == "VBR MP3" }
      .sorted { first, second in
        let firstTrack = first.track?.value ?? 0
        let secondTrack = second.track?.value ?? 0
        if firstTrack == secondTrack {
          return (first.title?.value ?? "") < (second.title?.value ?? "")
        }
        return firstTrack < secondTrack
      }
  }

  /// Builds playable ``Track`` values for the item's audio files, resolving each
  /// to a download URL with `urlGenerator`.
  func tracks(using urlGenerator: InternetArchive.URLGenerator) -> [Track] {
    guard let identifier = metadata?.identifier else { return [] }
    return sortedTracks.compactMap { file in
      guard let url = urlGenerator.generateDownloadUrl(
        itemIdentifier: identifier,
        fileName: file.name
      ) else { return nil }
      return Track(
        id: file.name,
        title: file.title?.value ?? file.name,
        trackNumber: file.track?.value,
        url: url
      )
    }
  }
}
