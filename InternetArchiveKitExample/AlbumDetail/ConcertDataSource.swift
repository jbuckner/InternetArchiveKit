//
//  ConcertDataSource.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import UIKit
import InternetArchiveKit

protocol ConcertDataSourceDelegate: class {
  func concertLoaded(concert: InternetArchive.Item)
}

class ConcertDataSource: NSObject {
  weak var delegate: ConcertDataSourceDelegate?
  var concertIdentifier: String? {
    didSet {
      loadConcert()
    }
  }
  private var concert: InternetArchive.Item? {
    didSet {
      guard let concert: InternetArchive.Item = self.concert else { return }
      self.delegate?.concertLoaded(concert: concert)
    }
  }
  private let internetArchive: InternetArchive

  init(concertIdentifier: String? = nil, internetArchive: InternetArchive = InternetArchive()) {
    self.concertIdentifier = concertIdentifier
    self.internetArchive = internetArchive
    super.init()
    self.loadConcert()
  }

  func loadConcert() {
    guard let concertIdentifier = concertIdentifier else { return }
    internetArchive.itemDetail(identifier: concertIdentifier) { (concert: InternetArchive.Item?, error: Error?) in
      self.concert = concert
    }
  }

  var trackCount: Int {
    return concert?.sortedTracks.count ?? 0
  }

  func getTrack(at index: Int) -> InternetArchive.File? {
    return concert?.sortedTracks[safe: index]
  }
}

extension ConcertDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return concert?.sortedTracks.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)

    guard let song: InternetArchive.File = concert?.sortedTracks[indexPath.row] else { return cell }
    let track: Int = song.track?.value ?? 0
    let title = song.title?.value ?? song.name?.value ?? "No title"
    cell.textLabel!.text = "\(track) \(title)"
    return cell
  }
}
