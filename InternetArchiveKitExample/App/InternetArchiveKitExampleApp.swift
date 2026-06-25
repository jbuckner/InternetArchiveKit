//
//  InternetArchiveKitExampleApp.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import SwiftUI

@main
struct InternetArchiveKitExampleApp: App {
  /// One audio player shared across the app so playback survives navigation.
  @State private var player = AudioPlayer()

  var body: some Scene {
    WindowGroup {
      ArtistsView()
        .environment(player)
    }
  }
}
