//
//  MasterViewController.swift
//  InternetArchiveSDKExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import UIKit
import InternetArchiveSDK

class EtreeCollectionViewController: UITableViewController {

  var detailViewController: ArtistDetailViewController? = nil
  var artists: [InternetArchive.ItemMetadata] = []

  var internetArchive: InternetArchive = InternetArchive()

  override func viewDidLoad() {
    super.viewDidLoad()
    if let split = splitViewController {
      let controllers = split.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ArtistDetailViewController
    }

    let query: String = "collection:(etree)+AND+mediatype:(collection)"
    internetArchive.search(
      query: query,
      fields: ["identifier", "title"],
      start: 0,
      rows: 10,
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        self.artists = response?.response.docs ?? []

        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
    })
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let object = artists[indexPath.row]
        let controller = (segue.destination as! UINavigationController).topViewController as! ArtistDetailViewController
        controller.detailItem = object
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return artists.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let artist: InternetArchive.ItemMetadata = artists[indexPath.row]
    cell.textLabel!.text = artist.title ?? "No title"
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      artists.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }


}

