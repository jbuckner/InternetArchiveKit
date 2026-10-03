//
//  AccessAndLicense.swift
//  InternetArchiveKit
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

/// archive.org's own limits on what a client may do with an item.
public struct AccessFlags: Sendable, Hashable, Codable {
  /// The item's `access-restricted-item` field is true.
  public let isAccessRestricted: Bool
  /// The item is in the `stream_only` collection.
  public let isStreamOnly: Bool
  /// The item's `is_dark` flag is set, so archive.org has taken it down.
  public let isDark: Bool

  /// Restricted, stream-only and dark items can't be downloaded.
  public var allowsDownloads: Bool {
    !isAccessRestricted && !isStreamOnly && !isDark
  }

  /// - Parameters:
  ///   - collections: the item's `collection` values.
  ///   - accessRestricted: the raw `access-restricted-item` value, if any.
  ///     "true", "yes" and "1" count as true, in any case.
  public init(collections: [String], accessRestricted: String?, isDark: Bool) {
    self.isAccessRestricted = Self.isTruthy(accessRestricted)
    self.isStreamOnly = collections.contains {
      $0.trimmingCharacters(in: .whitespaces).lowercased() == "stream_only"
    }
    self.isDark = isDark
  }

  private static func isTruthy(_ text: String?) -> Bool {
    switch text?.trimmingCharacters(in: .whitespaces).lowercased() {
    case "true", "yes", "1": return true
    default: return false
    }
  }
}

/// A license URL from an item's `licenseurl` field.
public struct License: Sendable, Hashable {
  public let url: URL

  public init(url: URL) {
    self.url = url
  }

  /// "CC BY-NC-ND 4.0", "CC0" or "Public Domain" for a Creative Commons URL.
  /// Nil for any other license, since there's no short name to give it.
  public var shortName: String? {
    guard url.host?.lowercased().hasSuffix("creativecommons.org") == true else { return nil }
    let parts = url.pathComponents.filter { $0 != "/" }.map { $0.lowercased() }
    guard parts.count >= 2, parts[0] == "licenses" || parts[0] == "publicdomain" else {
      return nil
    }
    if parts[0] == "publicdomain" {
      return parts[1] == "zero" ? "CC0" : "Public Domain"
    }
    if parts[1] == "publicdomain" { return "Public Domain" }
    let version = parts.count >= 3 ? " \(parts[2])" : ""
    return "CC \(parts[1].uppercased())\(version)"
  }

  /// CC0 and the public domain marks.
  public var isPublicDomain: Bool {
    shortName == "CC0" || shortName == "Public Domain"
  }
}
