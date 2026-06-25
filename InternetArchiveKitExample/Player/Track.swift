//
//  Track.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

/// A single playable audio file within a concert, resolved to a streaming URL.
struct Track: Identifiable, Hashable {
  /// The file name, which is unique within an Internet Archive item.
  let id: String
  let title: String
  let trackNumber: Int?
  let url: URL
}
