//
//  ConcertViewController.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import UIKit
import InternetArchiveSDK
import AVKit

class ConcertViewController: UITableViewController {
  var dataSource: ConcertDataSource?
  var concertIdentifier: String? {
    didSet {
      self.dataSource?.concertIdentifier = concertIdentifier
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = ConcertDataSource()
    self.tableView.dataSource = self.dataSource
    self.dataSource?.delegate = self
    self.dataSource?.concertIdentifier = concertIdentifier
  }

  var player: AVPlayer = AVPlayer()
}

extension ConcertViewController: ConcertDataSourceDelegate {
  func concertLoaded(concert: InternetArchive.Item) {
    DispatchQueue.main.async {
      self.navigationItem.title = concert.normalizedTitle
      self.tableView?.reloadData()
    }
  }
}

// MARK: UITableViewDelegate
extension ConcertViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard
      let itemIdentifier: String = self.concertIdentifier,
      let file: InternetArchive.File = self.dataSource?.getTrack(at: indexPath.row),
      let fileName: String = file.name
    else {
      tableView.deselectRow(at: indexPath, animated: true)
      return
    }

    let internetArchive: InternetArchive = InternetArchive()
    if let url = internetArchive.generateDownloadUrl(itemIdentifier: itemIdentifier, fileName: fileName) {
      debugPrint("downloadUrl", url)
      player.pause()
      player = AVPlayer(url: url)
      player.volume = 1.0
      player.play()
    }
  }
}
