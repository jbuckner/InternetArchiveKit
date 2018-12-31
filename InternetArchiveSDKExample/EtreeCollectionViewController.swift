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
  var filteredArtists: [InternetArchive.ItemMetadata] = []
  let searchController = UISearchController(searchResultsController: nil)

  var internetArchive: InternetArchive = InternetArchive()

  override func viewDidLoad() {
    super.viewDidLoad()
    if let split = splitViewController {
      let controllers = split.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ArtistDetailViewController
    }

    // Setup the Search Controller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Artists"
    navigationItem.searchController = searchController
    definesPresentationContext = true

    // Setup the Scope Bar
//    searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
    searchController.searchBar.delegate = self

    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection": "etree", "mediatype": "collection"])
    internetArchive.search(
      query: query,
      start: 0,
      rows: 10,
      fields: ["identifier", "title"],
      sortFields: [InternetArchive.SortField(field: "downloads", direction: .desc)],
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
    guard
      segue.identifier == "showDetail",
      let indexPath = tableView.indexPathForSelectedRow else { return }
    let object: InternetArchive.ItemMetadata
    if isFiltering() {
      object = filteredArtists[indexPath.row]
    } else {
      object = artists[indexPath.row]
    }

    let controller = (segue.destination as! UINavigationController).topViewController as! ArtistDetailViewController
    controller.detailItem = object
    controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    controller.navigationItem.leftItemsSupplementBackButton = true
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
//      searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
      return filteredArtists.count
    }

//    searchFooter.setNotFiltering()
    return artists.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let artist: InternetArchive.ItemMetadata
    if isFiltering() {
      artist = filteredArtists[indexPath.row]
    } else {
      artist = artists[indexPath.row]
    }

    cell.textLabel!.text = artist.title ?? "No title"
    return cell
  }

  private let searchDebouncer: Debouncer = Debouncer(delay: 1.0, callback: {})
}

extension EtreeCollectionViewController {
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    // first try to filter by artists already loaded
    filteredArtists = artists.filter({(artist : InternetArchive.ItemMetadata) -> Bool in
//      let doesCategoryMatch = (scope == "All") || (candy.category == scope)

//      if searchBarIsEmpty() {
//        return doesCategoryMatch
//      } else {
      return artist.title?.lowercased().contains(searchText.lowercased()) ?? false // & doesCategoryMatch
//      }
    })

    self.tableView.reloadData()

    // if search results found, reload, otherwise start an online search
    if filteredArtists.count == 0 {
      guard searchText.count > 0 else {
        self.tableView.reloadData()
        return
      }
      self.searchDebouncer.callback = {
        self.debounceSearch(searchText: searchText)
      }

      searchDebouncer.call()
    }
  }

  func debounceSearch(searchText: String) {
    debugPrint("starting debounced search", searchText)

    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection": "etree",
                                                                       "mediatype": "collection",
                                                                       "creator": "*\(searchText)*"])
    internetArchive.search(
      query: query,
      start: 0,
      rows: 50,
      fields: ["identifier", "title"],
      sortFields: [InternetArchive.SortField(field: "title", direction: .asc)],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        self.filteredArtists = response?.response.docs ?? []

        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
    })
  }

  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }

  func isFiltering() -> Bool {
    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
  }
}

extension EtreeCollectionViewController: UISearchBarDelegate {
  // MARK: - UISearchBar Delegate
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
  }
}

extension EtreeCollectionViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
//    let searchBar = searchController.searchBar
//    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    filterContentForSearchText(searchController.searchBar.text!, scope: "All")
  }
}
