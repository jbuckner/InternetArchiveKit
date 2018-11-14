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

  override func viewDidAppear(_ animated: Bool) {
    self.test()
    super.viewDidAppear(animated)
  }

  func test() {
    if let url = URL(string: "https://archive.org/download/testmp3testfile/mpthreetest.mp3") {
      player = AVPlayer(url: url)
      player.volume = 1.0
      player.play()
    }
  }
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
    
  }
}
