//
//  ScrapeViewController.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 6/24/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import UIKit
import InternetArchiveKit

/// Demonstrates the Scrape API.
///
/// `scrapeTotal()` fetches the match count up front (shown in the title), then
/// `scrape()`'s cursor pagination walks the entire `etree` collection in,
/// appending each batch until the cursor runs out. Pull to refresh to re-run.
class ScrapeViewController: UITableViewController {
  private let internetArchive: InternetArchive = InternetArchive()
  private let query: InternetArchive.Query = InternetArchive.Query(
    clauses: ["collection": "etree", "mediatype": "collection"])

  private var collections: [InternetArchive.ItemMetadata] = []
  private var total: Int?
  // `nil` requests the first batch at the server default size; a `.cursor`
  // resumes where the previous batch left off.
  private var nextPage: InternetArchive.ScrapePagination?
  private var isLoading: Bool = false
  private var reachedEnd: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(restart), for: .valueChanged)
    restart()
  }

  @objc private func restart() {
    collections = []
    total = nil
    nextPage = nil
    reachedEnd = false
    tableView.reloadData()
    fetchTotal()
    fetchNextBatch()
  }

  /// `scrapeTotal()` returns the match count without fetching any items.
  private func fetchTotal() {
    internetArchive.scrapeTotal(query: query) { [weak self] (total: Int?, _: Error?) in
      DispatchQueue.main.async {
        self?.total = total
        self?.updateTitle()
      }
    }
  }

  /// Fetch the next batch, then chain to the one after it until the Scrape API
  /// stops returning a cursor (which signals the end of the result set).
  private func fetchNextBatch() {
    guard !isLoading, !reachedEnd else { return }
    isLoading = true

    internetArchive.scrape(
      query: query,
      fields: ["identifier", "title"],
      pagination: nextPage,
      completion: { [weak self] (response: InternetArchive.ScrapeResponse?, _: Error?) in
        DispatchQueue.main.async {
          guard let self = self else { return }
          self.isLoading = false
          self.refreshControl?.endRefreshing()

          guard let response = response else { return }
          self.collections += response.items

          if let cursor = response.cursor {
            self.nextPage = .cursor(cursor)
            self.fetchNextBatch()  // keep scrolling forward
          } else {
            self.reachedEnd = true
          }

          self.updateTitle()
          self.tableView.reloadData()
        }
    })
  }

  private func updateTitle() {
    if let total = total {
      title = "etree \(collections.count)/\(total)"
    } else {
      title = "etree \(collections.count)"
    }
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collections.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")
      ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    let collection: InternetArchive.ItemMetadata = collections[indexPath.row]
    cell.textLabel?.text = collection.title?.value ?? collection.identifier
    cell.detailTextLabel?.text = collection.identifier
    return cell
  }
}
