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
  private weak var albumsViewController: AlbumSelectorViewController?
  var dataSource: AlbumsDataSource?

  func configureView() {
    // Update the user interface for the detail item.
    guard let detail = detailItem else { return }
    if let label = detailDescriptionLabel {
      label.text = detail.title ?? "No title"
    }

    self.dataSource = AlbumsDataSource(artist: detail)
    self.dataSource?.delegate = self
    self.tableView?.dataSource = self.dataSource
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.


    configureView()
//    debugPrint("didLoad", tableView)

  }

  var detailItem: InternetArchive.ItemMetadata? {
    didSet {
      configureView()
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "albums", let destination = segue.destination as? AlbumSelectorViewController {
      destination.artist = self.detailItem
      self.albumsViewController = destination
    }
  }
}

extension ArtistDetailViewController: AlbumDataSourceDelegate {
  func albumsLoaded() {
    DispatchQueue.main.async {
      self.tableView?.reloadData()
    }
  }
}
