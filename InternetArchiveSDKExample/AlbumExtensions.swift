//
//  ConcertExtensions.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import InternetArchiveSDK

extension InternetArchive.Item {
  // this goes through all of the files in an item, filters by `VBR MP3` format, then sorts by `track`
  var sortedSongs: [InternetArchive.File] {
    let onlySongs: [InternetArchive.File] = self.files?.filter { $0.format == "VBR MP3" } ?? []
    let sortedSongs: [InternetArchive.File] = onlySongs.sorted { (song: InternetArchive.File, song2: InternetArchive.File) -> Bool in
      guard
        let track1: Int = Int(song.track ?? "0"),
        let track2: Int = Int(song2.track ?? "0") else { return false }

      // If we have matching track numbers, it may mean track numbers were not provided. Try sorting by track
      // title. Sometimes recorders will prefix the track number on the title. It's better than nothing
      if track1 == track2 {
        return song.title ?? "" < song2.title ?? ""
      } else {
        return track1 < track2
      }
    }
    return sortedSongs
  }

  var normalizedTitle: String {
    return self.metadata?.normalizedTitle ?? "No title"
  }
}

extension InternetArchive.ItemMetadata {
  // the title usually includes the name of the band, such as "Yonder Mountain String Band Live at Red Rocks"
  // we just want to show "Live at Red Rocks" so this just strips the `creator` from `title`
  var normalizedTitle: String {
    guard
      let creator: String = self.creator,
      let title: String = self.title else {
        return self.title ?? "No title"
    }

    return title.replacingOccurrences(of: creator, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
