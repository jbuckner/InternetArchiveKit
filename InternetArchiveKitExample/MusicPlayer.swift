//
//  MusicPlayer.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/14/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer

protocol MusicPlayerProtocol: class {
  func didStartPlaying()
  func didPausePlaying()
  func didSkipTrack()
  func didGoBackTrack()
  func didPlayTrack(at index: Int)
  func trackDidChange()
}

class MusicPlayer: NSObject {
  static let shared: MusicPlayer = MusicPlayer()

  weak var delegate: MusicPlayerProtocol?
  var player: AVQueuePlayer = AVQueuePlayer()
  var playerItems: [AVPlayerItem] = []
  var isPlaying: Bool = false
  var currentTrackIndex: Int? {
    guard
      let currentTrack: AVPlayerItem = player.currentItem,
      let currentIndex: Int = self.playerItems.firstIndex(of: currentTrack)
      else { return nil }

    return currentIndex
  }

  override init() {
    super.init()

    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
    } catch {
      debugPrint("error setting category", error.localizedDescription)
    }

    self.setupLockScreenCommandCenter()
    self.player.addObserver(self, forKeyPath: "currentItem", options: .new, context: nil)
  }

  private func setupLockScreenCommandCenter() {
    let commandCenter = MPRemoteCommandCenter.shared()

    commandCenter.previousTrackCommand.isEnabled = true;
    commandCenter.previousTrackCommand.addTarget { (_:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
      self.prev()
      return .success
    }

    commandCenter.nextTrackCommand.isEnabled = true
    commandCenter.nextTrackCommand.addTarget { (_:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
      self.next()
      return .success
    }

    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { (_:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
      self.play()
      return .success
    }

    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { (_:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
      self.pause()
      return .success
    }
  }

  func playTrack(index: Int) {
    debugPrint("playTrack", index)
    self.pause()
    player.removeAllItems()
    for playerItem: AVPlayerItem in self.playerItems[index...] {
      player.insert(playerItem, after: nil)
    }
    player.seek(to: CMTime(seconds: 0, preferredTimescale: 1)) // if the song has already been played, seek back to the start
    self.play()
    self.delegate?.didPlayTrack(at: index)
  }

  func play() {
    self.isPlaying = true
    self.player.play()
//    MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist: "bar"]
    self.delegate?.didStartPlaying()
  }

  func pause() {
    self.isPlaying = false
    self.player.pause()
    self.delegate?.didPausePlaying()
  }

  func next() {
    self.player.advanceToNextItem()
    self.delegate?.didSkipTrack()
  }

  func prev() {
    let playerItems: [AVPlayerItem] = self.playerItems
    guard playerItems.count > 0 else { return }

    let trackIndexToPlay: Int
    if
      let currentTrackIndex: Int = currentTrackIndex,
      currentTrackIndex > 0 {
      trackIndexToPlay = currentTrackIndex - 1
    } else {
      trackIndexToPlay = player.items().count - 1
    }

    self.playTrack(index: trackIndexToPlay)
    self.delegate?.didGoBackTrack()
  }

  func jumpNearEnd() {
    guard let duration: CMTime = self.player.currentItem?.asset.duration else { return }
    let secondsNearEnd: CMTime = CMTime(seconds: 5.0, preferredTimescale: 1)
    let nearEnd: CMTime = CMTimeSubtract(duration, secondsNearEnd)
    self.player.seek(to: nearEnd)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard
      object is AVPlayer,
      let keyPath: String = keyPath
      else { return }

    switch keyPath {
    case "currentItem":
      self.delegate?.trackDidChange()
    default:
      debugPrint("keyPath", keyPath)
    }
  }
}
