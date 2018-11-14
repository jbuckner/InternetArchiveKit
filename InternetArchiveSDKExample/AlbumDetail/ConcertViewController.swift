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
  @IBOutlet weak var playPauseBtn: UIBarButtonItem!

  private var isPlaying: Bool = false
  
  @IBAction func playPause(_ sender: UIBarButtonItem) {
    if self.isPlaying {
      self.pause()
    } else {
      self.play()
    }
  }

  func play() {
    self.player.play()
    self.playPauseBtn.title = "Pause"
    self.isPlaying = true
  }

  func pause() {
    self.player.pause()
    self.playPauseBtn.title = "Play"
    self.isPlaying = false
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = ConcertDataSource()
    self.tableView?.dataSource = self.dataSource
    self.tableView?.delegate = self
    self.dataSource?.delegate = self
    self.dataSource?.concertIdentifier = concertIdentifier
  }

  var player: AVPlayer = AVPlayer()
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

    let internetArchive: InternetArchive = InternetArchive()
    if let url = internetArchive.generateDownloadUrl(itemIdentifier: itemIdentifier, fileName: fileName) {
      debugPrint("downloadUrl", url)
      self.pause()
      self.player = AVPlayer(url: url)
      self.player.volume = 1.0
      self.play()
    }
  }
}
