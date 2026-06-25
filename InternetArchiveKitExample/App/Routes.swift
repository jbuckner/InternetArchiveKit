//
//  Routes.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

/// A navigation value identifying an artist whose concerts to show.
///
/// `InternetArchive.ItemMetadata` isn't `Hashable`, so screens push these small
/// value types instead of the metadata itself.
struct ArtistRoute: Hashable {
  let identifier: String
  let title: String
}

/// A navigation value identifying a single concert to open.
struct ConcertRoute: Hashable {
  let identifier: String
  let title: String
}
