//
//  AlbumDataSource.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import UIKit
import InternetArchiveSDK

protocol AlbumDataSourceDelegate: class {
  func albumLoaded(album: InternetArchive.Item)
}

class AlbumDataSource: NSObject {
  weak var delegate: AlbumDataSourceDelegate?
  var albumIdentifier: String? {
    didSet {
      loadAlbum()
    }
  }
  private let internetArchive: InternetArchive
  private var album: InternetArchive.Item? {
    didSet {
      guard let album: InternetArchive.Item = self.album else { return }
      self.delegate?.albumLoaded(album: album)
    }
  }

  init(albumIdentifier: String? = nil, internetArchive: InternetArchive = InternetArchive()) {
    self.albumIdentifier = albumIdentifier
    self.internetArchive = internetArchive
    super.init()
    self.loadAlbum()
  }

  func loadAlbum() {
    guard let albumIdentifier = albumIdentifier else { return }
    internetArchive.itemDetail(identifier: albumIdentifier) { (album: InternetArchive.Item?, error: Error?) in
      self.album = album
    }
  }
}

extension AlbumDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return album?.sortedSongs.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)

    guard let song: InternetArchive.File = album?.sortedSongs[indexPath.row] else { return cell }
    let track = song.track ?? "?"
    let title = song.title ?? "No title"
    cell.textLabel!.text = "\(track) \(title)"
    return cell
  }
}
