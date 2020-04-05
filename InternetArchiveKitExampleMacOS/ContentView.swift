//
//  ContentView.swift
//  InternetArchiveKitExampleMacOS
//
//  Created by Jason Buckner on 4/5/20.
//  Copyright © 2020 Jason Buckner. All rights reserved.
//

import SwiftUI

struct ArtistRow: View {
  var artist: Artist

  var body: some View {
    Text(artist.name ?? "No name given")
  }
}

struct ContentView: View {
  @Environment(\.managedObjectContext) var context

  @FetchRequest(
    entity: Artist.entity(),
    sortDescriptors: [NSSortDescriptor(keyPath: \Artist.name, ascending: false)],
    predicate: nil
  ) var artists: FetchedResults<Artist>

  // this is the variable we added
  @State private var artistName: String = ""

  var body: some View {
    List {
      ForEach(artists, id: \.identifier) { artist in
        ArtistRow(artist: artist)
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
