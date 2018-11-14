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
}

extension ConcertViewController: ConcertDataSourceDelegate {
  func concertLoaded(concert: InternetArchive.Item) {
    DispatchQueue.main.async {
      self.navigationItem.title = concert.normalizedTitle
      self.tableView?.reloadData()
    }
  }
}
