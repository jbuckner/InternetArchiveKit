//
//  AlbumExtensions.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import InternetArchiveSDK

extension InternetArchive.Item {
  var sortedSongs: [InternetArchive.File] {
    let onlySongs: [InternetArchive.File] = self.files?.filter { (file: InternetArchive.File) -> Bool in
      file.format == "VBR MP3"
      } ?? []
    let sortedSongs: [InternetArchive.File] = onlySongs.sorted { (song: InternetArchive.File, song2: InternetArchive.File) -> Bool in
      guard
        let track1: Int = Int(song.track ?? "0"),
        let track2: Int = Int(song2.track ?? "0") else { return false }
      return track1 < track2
    }
    return sortedSongs
  }

  var normalizedTitle: String {
    return self.metadata?.normalizedTitle ?? ""
  }
}

extension InternetArchive.ItemMetadata {
  var normalizedTitle: String {
    guard
      let creator: String = self.creator,
      let title: String = self.title else {
        return self.title ?? ""
    }

    return title.replacingOccurrences(of: creator, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
