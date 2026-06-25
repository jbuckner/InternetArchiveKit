//
//  ItemMetadata+Display.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import InternetArchiveKit

extension InternetArchive.ItemMetadata {
  /// The title to show in lists, falling back to the identifier.
  var displayTitle: String {
    title?.value ?? identifier
  }

  /// The venue to show for a concert, falling back to a placeholder.
  var displayVenue: String {
    venue?.value ?? "Unknown venue"
  }

  /// The concert date formatted as `yyyy-MM-dd`, or `nil` when absent.
  var displayDate: String? {
    guard let date = date?.value else { return nil }
    return Self.dateFormatter.string(from: date)
  }

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
}
