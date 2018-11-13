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
  func albumLoaded()
}

class AlbumDataSource: NSObject {
  weak var delegate: AlbumDataSourceDelegate?
  var albumIdentifier: String? {
    didSet {
      loadAlbum()
    }
  }
//  private var album: InternetArchive.Item? {
//    get
//  }
  private let internetArchive: InternetArchive
  private var songs: [InternetArchive.File] = []

  init(albumIdentifier: String? = nil, internetArchive: InternetArchive = InternetArchive()) {
    self.albumIdentifier = albumIdentifier
    self.internetArchive = internetArchive
    super.init()
    self.loadAlbum()
  }

  func loadAlbum() {
    guard let albumIdentifier = albumIdentifier else { return }
    internetArchive.itemDetail(identifier: albumIdentifier) { (album: InternetArchive.Item?, error: Error?) in
      guard let files = album?.files else { return }
      self.songs = self.sortSongs(files: files)
      self.delegate?.albumLoaded()
    }
  }

  private func sortSongs(files: [InternetArchive.File]) -> [InternetArchive.File] {
    let onlySongs: [InternetArchive.File] = files.filter { (file: InternetArchive.File) -> Bool in
      file.format == "VBR MP3"
    }
    let sortedSongs: [InternetArchive.File] = onlySongs.sorted { (song: InternetArchive.File, song2: InternetArchive.File) -> Bool in
      guard
        let track1: Int = Int(song.track ?? "0"),
        let track2: Int = Int(song2.track ?? "0") else { return false }
      return track1 < track2
    }
    return sortedSongs
  }
}

extension AlbumDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return songs.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)

    let song: InternetArchive.File = songs[indexPath.row]
    let track = song.track ?? "?"
    let title = song.title ?? "No title"
    cell.textLabel!.text = "\(track) \(title)"
    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      songs.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }
}
