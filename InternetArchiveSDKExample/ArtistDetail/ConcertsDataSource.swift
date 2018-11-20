//
//  ConcertDataSource.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import UIKit
import InternetArchiveSDK

protocol ConcertsDataSourceDelegate: class {
  func concertsLoaded(concerts: [InternetArchive.ItemMetadata])
}

class ConcertsDataSource: NSObject {
  weak var delegate: ConcertsDataSourceDelegate?
  var artist: InternetArchive.ItemMetadata? {
    didSet {
      self.loadConcerts()
    }
  }
  var concerts: [InternetArchive.ItemMetadata] = []
  private let internetArchive: InternetArchive

  init(artist: InternetArchive.ItemMetadata? = nil, internetArchive: InternetArchive = InternetArchive()) {
    self.artist = artist
    self.internetArchive = internetArchive
    super.init()
    self.loadConcerts()
    dateFormatter.dateFormat = "yyyy-MM-dd"
  }

  func loadConcerts() {
    guard let artist = artist else { return }
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : artist.identifier])

    internetArchive.search(
      query: query,
      start: 0,
      rows: 100,
      fields: ["identifier", "title", "creator", "venue", "date"],
      sortFields: [InternetArchive.SortField(field: "date", direction: .desc)],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        guard let concerts: [InternetArchive.ItemMetadata] = response?.response.docs else { return }
        self.concerts = concerts
        self.delegate?.concertsLoaded(concerts: concerts)
    })
  }

  private let dateFormatter: DateFormatter = DateFormatter()
}

extension ConcertsDataSource: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return concerts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "concertCell", for: indexPath)

    let concert: InternetArchive.ItemMetadata = concerts[indexPath.row]

    let datePrefix: String
    if let concertDate: Date = concert.date {
      datePrefix = "\(dateFormatter.string(from: concertDate)): "
    } else {
      datePrefix = ""
    }

    let venue: String = concert.venue ?? "Unknown venue"

    cell.textLabel!.text = "\(datePrefix)\(venue)"
    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      concerts.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }
}
