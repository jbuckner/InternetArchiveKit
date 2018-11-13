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
  func albumsLoaded()
}

class AlbumsDataSource: NSObject {
  weak var delegate: AlbumDataSourceDelegate?
  var artist: InternetArchive.ItemMetadata {
    didSet {
      self.loadAlbums()
    }
  }
  private let internetArchive: InternetArchive
  private var albums: [InternetArchive.ItemMetadata] = []

  init(artist: InternetArchive.ItemMetadata, internetArchive: InternetArchive = InternetArchive()) {
    self.artist = artist
    self.internetArchive = internetArchive
    super.init()
    self.loadAlbums()
  }

  private func loadAlbums() {
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : artist.identifier])

    internetArchive.search(
      query: query,
      start: 0,
      rows: 10,
      fields: ["identifier", "title"],
      sortFields: [InternetArchive.SortField(field: "date", direction: .asc)],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        self.albums = response?.response.docs ?? []
        self.delegate?.albumsLoaded()
    })
  }
}

extension AlbumsDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return albums.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath)

    let album: InternetArchive.ItemMetadata = albums[indexPath.row]
    cell.textLabel!.text = album.title ?? "No title"
    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      albums.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }
}
