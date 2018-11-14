//
//  DetailViewController.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import UIKit
import InternetArchiveSDK

class ArtistDetailViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var detailDescriptionLabel: UILabel?
  var dataSource: AlbumsDataSource?

  func configureView() {
    // Update the user interface for the detail item.
    guard let detail = detailItem else { return }
    if let label = detailDescriptionLabel {
      label.text = detail.normalizedTitle
    }

    self.dataSource?.artist = detail
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = AlbumsDataSource()
    self.dataSource?.delegate = self
    self.tableView?.dataSource = self.dataSource
    configureView()
  }

  override func viewWillAppear(_ animated: Bool) {
    if let tableView: UITableView = self.tableView,
      let selectedIndexPath: IndexPath = self.tableView?.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    super.viewWillAppear(animated)
  }

  var detailItem: InternetArchive.ItemMetadata? {
    didSet {
      configureView()
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "albumSegue",
      let destination = (segue.destination as? UINavigationController)?.topViewController as? AlbumViewController,
      let indexPath = tableView?.indexPathForSelectedRow,
      let album = self.dataSource?.albums[indexPath.row] else { return }

    destination.albumIdentifier = album.identifier
    destination.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    destination.navigationItem.leftItemsSupplementBackButton = true
  }
}

extension ArtistDetailViewController: AlbumsDataSourceDelegate {
  func albumsLoaded(albums: [InternetArchive.ItemMetadata]) {
    DispatchQueue.main.async {
      self.tableView?.reloadData()
    }
  }
}
