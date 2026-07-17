//
//  ChangesResponse.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   Where a `changes()` request starts reading the change feed.

   Pass nil to `changes(start:)` to read from the current head. Use
   `.coldStart` to enumerate every item, `.startDate` for changes since a
   date, and `.token` to continue from a previous response's `nextToken`.
   */
  public enum ChangesStart: Sendable {
    /// Enumerate all items from the beginning, then stream changes
    case coldStart
    /// Changes since the given date (sent as `YYYYMMDD`, UTC)
    case startDate(Date)
    /// Continue from a previous response's `nextToken`
    case token(String)
  }

  /**
   One batch from the Changes API.

   Pass `nextToken` back to `changes(start: .token(...))` to fetch the next
   batch. `doSleepBeforeReturning` is the API's advice to pause before the
   next request.
   */
  public struct ChangesResponse: Decodable, Sendable {
    /// One changed item
    public struct Change: Decodable, Sendable {
      public let identifier: String

      public init(identifier: String) {
        self.identifier = identifier
      }
    }

    /// The items that changed in this batch
    public let changes: [Change]
    /// The token for the next batch
    public let nextToken: String?
    /// Roughly how far this batch is from the head of the feed
    public let estimatedDistanceFromHead: Int?
    /// Whether the API advises pausing before the next request
    public let doSleepBeforeReturning: Bool?

    public init(
      changes: [Change],
      nextToken: String? = nil,
      estimatedDistanceFromHead: Int? = nil,
      doSleepBeforeReturning: Bool? = nil
    ) {
      self.changes = changes
      self.nextToken = nextToken
      self.estimatedDistanceFromHead = estimatedDistanceFromHead
      self.doSleepBeforeReturning = doSleepBeforeReturning
    }
  }
}
