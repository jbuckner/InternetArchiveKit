//
//  AlbumViewController.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import UIKit
import InternetArchiveSDK

class AlbumViewController: UITableViewController {
  var dataSource: AlbumDataSource?
  var albumIdentifier: String? {
    didSet {
      self.dataSource?.albumIdentifier = albumIdentifier
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = AlbumDataSource()
    self.tableView.dataSource = self.dataSource
    self.dataSource?.delegate = self
    self.dataSource?.albumIdentifier = albumIdentifier
  }
}

extension AlbumViewController: AlbumDataSourceDelegate {
  func albumLoaded() {
    DispatchQueue.main.async {
      self.tableView?.reloadData()
    }
  }
}
