//
//  ConcertExtensions.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import InternetArchiveKit

extension InternetArchive.Item {
  // this goes through all of the files in an item, filters by `VBR MP3` format, then sorts by `track`
  var sortedTracks: [InternetArchive.File] {
    let onlyTracks: [InternetArchive.File] = self.files?.filter { $0.format?.value == "VBR MP3" } ?? []
    let sortedTracks: [InternetArchive.File] = onlyTracks.sorted { (song: InternetArchive.File, song2: InternetArchive.File) -> Bool in
      let track1: Int = song.track?.value ?? 0
      let track2: Int = song2.track?.value ?? 0

      // If we have matching track numbers, it may mean track numbers were not provided. Try sorting by track
      // title. Sometimes recorders will prefix the track number on the title. It's better than nothing
      if track1 == track2 {
        return song.title?.value ?? "" < song2.title?.value ?? ""
      } else {
        return track1 < track2
      }
    }
    return sortedTracks
  }
}
