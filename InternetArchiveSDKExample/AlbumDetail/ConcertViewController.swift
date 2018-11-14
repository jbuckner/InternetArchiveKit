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
  var currentlyPlayingIndex: Int?
  
  @objc func playPause(_ sender: UIBarButtonItem) {
    if self.isPlaying {
      self.pause()
    } else {
      self.play()
    }
  }

  @objc func skip(_ sender: UIBarButtonItem) {
    self.playSong(index: (currentlyPlayingIndex ?? -1) + 1)
  }

  @objc func back(_ sender: UIBarButtonItem) {
    let trackCount: Int = self.dataSource?.trackCount ?? 0
    self.playSong(index: (currentlyPlayingIndex ?? trackCount) - 1)
  }

  @objc func jumpNearEnd(_ sender: UIBarButtonItem) {
    guard let duration: CMTime = self.player.currentItem?.asset.duration else { return }
    let secondsNearEnd: CMTime = CMTime(seconds: 5.0, preferredTimescale: 1)
    let nearEnd: CMTime = CMTimeSubtract(duration, secondsNearEnd)
    self.player.seek(to: nearEnd)
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
    let rewind: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(back(_:)))
    let space1: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    let playPause: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: playPauseType, target: self, action: #selector(playPause(_:)))
    let space2: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    let fastforward: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: #selector(skip(_:)))
    let rightSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let fastforward2: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: nil, action: #selector(jumpNearEnd(_:)))

    space1.width = 42
    space2.width = 42

    self.toolbar.items = [leftSpace, rewind, space1, playPause, space2, fastforward, rightSpace, fastforward2]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = ConcertDataSource()
    self.tableView?.dataSource = self.dataSource
    self.tableView?.delegate = self
    self.dataSource?.delegate = self
    self.dataSource?.concertIdentifier = concertIdentifier
    self.updateToolbar()

    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                           name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                           object: player.currentItem)
  }

  @objc func playerDidFinishPlaying() {
    self.playSong(index: (currentlyPlayingIndex ?? 0) + 1)
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

extension ConcertViewController {
  func playSong(index: Int) {
    let indexPath: IndexPath = IndexPath(row: index, section: 0)

    guard
      let itemIdentifier: String = self.concertIdentifier,
      let file: InternetArchive.File = self.dataSource?.getTrack(at: index),
      let fileName: String = file.name
      else {
        self.tableView?.deselectRow(at: indexPath, animated: true)
        return
    }

    if let url = self.internetArchive.generateDownloadUrl(itemIdentifier: itemIdentifier, fileName: fileName) {
      debugPrint("downloadUrl", url)
      self.pause()
      self.player = AVPlayer(url: url)
      self.player.volume = 1.0
      self.currentlyPlayingIndex = index
      self.play()
      self.tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
  }
}

// MARK: UITableViewDelegate
extension ConcertViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.playSong(index: indexPath.row)
  }
}
