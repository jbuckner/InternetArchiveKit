//
//  ScrapeView.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 6/24/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import InternetArchiveKit
import SwiftUI

/// Demonstrates the Scrape API by walking the entire `etree` collection with
/// cursor pagination. The title tracks loaded-vs-total as batches arrive; pull
/// to refresh re-runs the walk.
struct ScrapeView: View {
  @State private var viewModel = ScrapeViewModel()

  var body: some View {
    List(viewModel.collections, id: \.identifier) { collection in
      VStack(alignment: .leading, spacing: 2) {
        Text(collection.displayTitle)
        Text(collection.identifier)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .overlay { statusOverlay }
    .refreshable { await viewModel.loadAll() }
    .task { await viewModel.loadAll() }
  }

  private var title: String {
    if let total = viewModel.total {
      return "etree \(viewModel.collections.count)/\(total)"
    }
    return "etree \(viewModel.collections.count)"
  }

  @ViewBuilder
  private var statusOverlay: some View {
    if viewModel.isLoading && viewModel.collections.isEmpty {
      ProgressView()
    } else if let error = viewModel.errorMessage, viewModel.collections.isEmpty {
      ContentUnavailableView(
        "Couldn't Scrape",
        systemImage: "wifi.slash",
        description: Text(error)
      )
    }
  }
}
