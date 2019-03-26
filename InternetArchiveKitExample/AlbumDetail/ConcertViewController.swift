//
//  ConcertViewController.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import UIKit
import InternetArchiveKit
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

  @objc func playPause(_ sender: UIBarButtonItem) {
    if self.musicPlayer.isPlaying {
      self.musicPlayer.pause()
    } else {
      self.musicPlayer.play()
    }
  }

  @objc func skip(_ sender: UIBarButtonItem) {
    debugPrint("skip")
    self.musicPlayer.next()
  }

  @objc func back(_ sender: UIBarButtonItem) {
    debugPrint("back")
    if self.musicPlayer.player.currentTime().seconds > 5 {
      debugPrint("jump to beginning")
      self.musicPlayer.player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    } else {
      debugPrint("jump to previous track")
      self.musicPlayer.prev()
    }
  }

  @objc func jumpNearEnd(_ sender: UIBarButtonItem) {
    self.musicPlayer.jumpNearEnd()
  }

  func updateToolbar() {
    let playPauseType: UIBarButtonItem.SystemItem = self.musicPlayer.isPlaying ? .pause : .play

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

  func updateCurrentItemSelection() {
    guard let currentTrackIndex: Int = self.musicPlayer.currentTrackIndex else { return }
    let indexPath: IndexPath = IndexPath(row: currentTrackIndex, section: 0)
    self.tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.dataSource = ConcertDataSource()
    self.tableView?.dataSource = self.dataSource
    self.tableView?.delegate = self
    self.dataSource?.delegate = self
    self.dataSource?.concertIdentifier = concertIdentifier
    self.updateToolbar()
    self.musicPlayer.delegate = self
  }

  @objc func trackDidFinishPlaying() {
    debugPrint("trackDidFinishPlaying")
  }

  func populateMusicPlayerWithItems() {
    self.musicPlayer.pause()
    self.musicPlayer.playerItems = self.playerItems
  }

  var musicPlayer: MusicPlayer = MusicPlayer.shared
  var internetArchive: InternetArchive = InternetArchive()
  var playerItems: [AVPlayerItem] = []
}

extension ConcertViewController: ConcertDataSourceDelegate {
  func concertLoaded(concert: InternetArchive.Item) {
    guard let concertIdentifier: String = concert.metadata?.identifier else { return }

    for track: InternetArchive.File in concert.sortedTracks {
      guard
        let fileName: String = track.name?.value,
        let url: URL = self.internetArchive.generateDownloadUrl(itemIdentifier: concertIdentifier, fileName: fileName)
        else { continue }

      let playerItem: AVPlayerItem = AVPlayerItem(url: url)
      self.playerItems.append(playerItem)
    }

    DispatchQueue.main.async {
      self.navigationItem.title = concert.metadata?.venue?.value ?? "No venue"
      self.tableView?.reloadData()
    }
  }
}

// MARK: UITableViewDelegate
extension ConcertViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    debugPrint("didSelectRow", indexPath.row)
    self.populateMusicPlayerWithItems()
    self.musicPlayer.playTrack(index: indexPath.row)
  }
}

extension ConcertViewController: MusicPlayerProtocol {
  func trackDidChange() {
    self.updateCurrentItemSelection()
  }

  func didStartPlaying() {
    self.updateToolbar()
  }

  func didPausePlaying() {
    self.updateToolbar()
  }

  func didSkipTrack() {

  }

  func didGoBackTrack() {

  }

  func didPlayTrack(at index: Int) {
    self.updateCurrentItemSelection()
    self.updateToolbar()
  }
}
