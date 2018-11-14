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

class ConcertViewController: UIViewController {
  var dataSource: ConcertDataSource?
  var concertIdentifier: String? {
    didSet {
      self.dataSource?.concertIdentifier = concertIdentifier
    }
  }

  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var toolbar: UIToolbar!

  private var isPlaying: Bool = false
  
  @objc func playPause(_ sender: UIBarButtonItem) {
    if self.isPlaying {
      self.pause()
    } else {
      self.play()
    }
  }

  func play() {
    self.isPlaying = true
    self.player.play()
    self.updateToolbar()
  }

  func pause() {
    self.isPlaying = false
    self.player.pause()
    self.updateToolbar()
  }

  func updateToolbar() {
    let playPauseType: UIBarButtonItem.SystemItem = isPlaying ? .pause : .play

    let leftSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let rewind: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: nil, action: nil)
    let space1: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    let playPause: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: playPauseType, target: self, action: #selector(playPause(_:)))
    let space2: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    let fastforward: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: nil)
    let rightSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    space1.width = 42
    space2.width = 42

    self.toolbar.items = [leftSpace, rewind, space1, playPause, space2, fastforward, rightSpace]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = ConcertDataSource()
    self.tableView?.dataSource = self.dataSource
    self.tableView?.delegate = self
    self.dataSource?.delegate = self
    self.dataSource?.concertIdentifier = concertIdentifier
    self.updateToolbar()
  }

  var player: AVPlayer = AVPlayer()
  var internetArchive: InternetArchive = InternetArchive()
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
extension ConcertViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard
      let itemIdentifier: String = self.concertIdentifier,
      let file: InternetArchive.File = self.dataSource?.getTrack(at: indexPath.row),
      let fileName: String = file.name
    else {
      tableView.deselectRow(at: indexPath, animated: true)
      return
    }

    if let url = self.internetArchive.generateDownloadUrl(itemIdentifier: itemIdentifier, fileName: fileName) {
      debugPrint("downloadUrl", url)
      self.pause()
      self.player = AVPlayer(url: url)
      self.player.volume = 1.0
      self.play()
    }
  }
}
