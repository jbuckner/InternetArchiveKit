//
//  ItemViews.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   View counts for a single item, from the Views Data Service.

   This will be returned from a `views()` request, keyed by item identifier.
   */
  public struct ItemViews: Decodable, Sendable {
    /// Whether the service has view data for the item
    public let haveData: Bool
    /// Views across all time
    public let allTime: Int
    /// Views in the last 30 days
    public let last30Day: Int
    /// Views in the last 7 days
    public let last7Day: Int

    enum CodingKeys: String, CodingKey {
      case haveData = "have_data"
      case allTime = "all_time"
      case last30Day = "last_30day"
      case last7Day = "last_7day"
    }

    public init(haveData: Bool, allTime: Int, last30Day: Int, last7Day: Int) {
      self.haveData = haveData
      self.allTime = allTime
      self.last30Day = last30Day
      self.last7Day = last7Day
    }
  }
}
