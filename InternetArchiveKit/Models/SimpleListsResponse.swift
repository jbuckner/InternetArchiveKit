//
//  SimpleListsResponse.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   An item's simple list memberships, from
   `/metadata/{identifier}/simplelists`.

   `result` is keyed by list name, then by parent item identifier. To go the
   other way (all members of a list), use `search()` with a
   `simplelists__{list-name}:{parent-item}` query clause.
   */
  public struct SimpleListsResponse: Decodable, Sendable {
    /// list name → parent item identifier → membership
    public let result: [String: [String: SimpleListMembership]]

    public init(result: [String: [String: SimpleListMembership]]) {
      self.result = result
    }
  }

  /**
   One membership entry in a simple list.

   The API also serves a free-form `notes` blob per membership; it has no
   documented shape, so it isn't modeled here.
   */
  public struct SimpleListMembership: Decodable, Sendable {
    /// When the membership last changed, e.g. `2020-04-14 08:27:01.453137`
    public let sysLastChanged: String?

    enum CodingKeys: String, CodingKey {
      case sysLastChanged = "sys_last_changed"
    }

    public init(sysLastChanged: String?) {
      self.sysLastChanged = sysLastChanged
    }
  }
}
