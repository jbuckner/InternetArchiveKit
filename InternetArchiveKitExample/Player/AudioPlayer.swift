//
//  AudioPlayer.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/14/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import AVFoundation
import Combine
import MediaPlayer
import Observation

/// Streams a concert's tracks with an `AVQueuePlayer` and mirrors playback state
/// into observable properties the SwiftUI views read.
///
/// It also wires up the lock-screen transport controls and now-playing info.
@MainActor
@Observable
final class AudioPlayer {
  /// The tracks currently queued for playback.
  private(set) var tracks: [Track] = []

  /// The index of the playing track within ``tracks``, or `nil` when stopped.
  private(set) var currentIndex: Int?

  /// Whether audio is actively playing.
  private(set) var isPlaying = false

  /// The track the player is currently on, if any.
  var currentTrack: Track? {
    guard let currentIndex, tracks.indices.contains(currentIndex) else { return nil }
    return tracks[currentIndex]
  }

  @ObservationIgnored private let player = AVQueuePlayer()
  /// The player items currently in the queue, used to map `currentItem` back to
  /// a track index.
  @ObservationIgnored private var queuedItems: [AVPlayerItem] = []
  /// The index in ``tracks`` of the first item in ``queuedItems``.
  @ObservationIgnored private var queueStartIndex = 0
  @ObservationIgnored private var cancellables: Set<AnyCancellable> = []

  init() {
    configureAudioSession()
    configureRemoteCommands()
    observePlayer()
  }

  // MARK: - Queue control

  /// Loads a concert's tracks without starting playback.
  func setQueue(_ tracks: [Track]) {
    self.tracks = tracks
  }

  /// Plays from the track at `index`, queuing every following track behind it.
  func play(at index: Int) {
    guard tracks.indices.contains(index) else { return }
    player.removeAllItems()
    queuedItems = tracks[index...].map { AVPlayerItem(url: $0.url) }
    queueStartIndex = index
    for item in queuedItems {
      player.insert(item, after: nil)
    }
    player.seek(to: .zero)
    player.play()
  }

  func togglePlayPause() {
    isPlaying ? player.pause() : player.play()
  }

  func next() {
    player.advanceToNextItem()
  }

  /// Restarts the current track when more than five seconds in, otherwise steps
  /// back to the previous track.
  func previous() {
    guard let currentIndex else { return }
    if player.currentTime().seconds > 5 {
      play(at: currentIndex)
    } else {
      play(at: max(currentIndex - 1, 0))
    }
  }

  // MARK: - Setup

  private func configureAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      debugPrint("Audio session setup failed:", error.localizedDescription)
    }
  }

  /// Observes the player's queue and play/pause state via typed key paths,
  /// delivering changes on the main queue.
  private func observePlayer() {
    player.publisher(for: \.currentItem)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] item in self?.handleCurrentItemChange(to: item) }
      .store(in: &cancellables)

    player.publisher(for: \.timeControlStatus)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        self?.isPlaying = status == .playing
        self?.updateNowPlayingInfo()
      }
      .store(in: &cancellables)
  }

  private func handleCurrentItemChange(to item: AVPlayerItem?) {
    if let item, let offset = queuedItems.firstIndex(where: { $0 === item }) {
      currentIndex = queueStartIndex + offset
    } else if item == nil {
      currentIndex = nil
    }
    updateNowPlayingInfo()
  }

  // MARK: - Lock screen

  private func configureRemoteCommands() {
    let center = MPRemoteCommandCenter.shared()
    center.playCommand.addTarget { [weak self] _ in
      Task { @MainActor in self?.player.play() }
      return .success
    }
    center.pauseCommand.addTarget { [weak self] _ in
      Task { @MainActor in self?.player.pause() }
      return .success
    }
    center.nextTrackCommand.addTarget { [weak self] _ in
      Task { @MainActor in self?.next() }
      return .success
    }
    center.previousTrackCommand.addTarget { [weak self] _ in
      Task { @MainActor in self?.previous() }
      return .success
    }
  }

  private func updateNowPlayingInfo() {
    var info: [String: Any] = [:]
    if let currentTrack {
      info[MPMediaItemPropertyTitle] = currentTrack.title
      if let number = currentTrack.trackNumber {
        info[MPMediaItemPropertyAlbumTrackNumber] = number
      }
    }
    info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
  }
}
