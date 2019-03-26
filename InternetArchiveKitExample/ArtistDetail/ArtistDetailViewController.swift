//
//  DetailViewController.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import UIKit
import InternetArchiveKit

class ArtistDetailViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var detailDescriptionLabel: UILabel?
  var dataSource: ConcertsDataSource?

  func configureView() {
    // Update the user interface for the detail item.
    guard let detail = detailItem else { return }
    if let label = detailDescriptionLabel {
      label.text = detail.title?.value ?? "No title"
    }

    self.dataSource?.artist = detail
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = ConcertsDataSource()
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
    guard segue.identifier == "concertSegue",
      let destination = (segue.destination as? UINavigationController)?.topViewController as? ConcertViewController,
      let indexPath = tableView?.indexPathForSelectedRow,
      let concert = self.dataSource?.concerts[indexPath.row] else { return }

    destination.concertIdentifier = concert.identifier
    destination.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    destination.navigationItem.leftItemsSupplementBackButton = true
  }
}

extension ArtistDetailViewController: ConcertsDataSourceDelegate {
  func concertsLoaded(concerts: [InternetArchive.ItemMetadata]) {
    DispatchQueue.main.async {
      self.tableView?.reloadData()
    }
  }
}
