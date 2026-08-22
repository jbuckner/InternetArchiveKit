//
//  Item.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   An Internet Archive Item, containing `ItemMetadata`, an array of `File` objects, and additional properties.

   This will be returned from an `InternetArchive().itemDetail()` request.
   */
  public struct Item: Codable, Sendable {
    /// Where else this item's files can be fetched from, if the primary server is busy
    public struct AlternateLocations: Codable, Sendable {
      /// A server holding a copy of the item, and the path to it on that server
      public struct Location: Codable, Sendable {
        public let server: String?
        public let dir: String?

        public init(server: String? = nil, dir: String? = nil) {
          self.server = server
          self.dir = dir
        }
      }

      /// Every server holding a copy
      public let servers: [Location]?
      /// The subset currently able to serve requests
      public let workable: [Location]?

      public init(servers: [Location]? = nil, workable: [Location]? = nil) {
        self.servers = servers
        self.workable = workable
      }
    }

    public let alternateLocations: AlternateLocations?
    public let created: ModelField<IAEpochDate>?
    public let collection: ModelField<IAString>?
    public let creator: ModelField<IAString>?
    public let metadata: ItemMetadata?
    public let d1: ModelField<IAString>?
    public let d2: ModelField<IAString>?
    public let dir: ModelField<IAString>?
    public let isCollection: ModelField<IABool>?
    public let isDark: Bool?
    public let itemLastUpdated: ModelField<IAEpochDate>?
    public let filesCount: ModelField<IAInt>?
    public let itemSize: ModelField<IAInt>?
    public let server: ModelField<IAString>?
    public let serversUnavailable: Bool?
    public let uniq: ModelField<IAInt>?
    public let workableServers: ModelField<IAString>?
    public let files: [File]?
    public let reviews: [Review]?

    public init(
      alternateLocations: AlternateLocations? = nil,
      created: ModelField<IAEpochDate>? = nil,
      collection: ModelField<IAString>? = nil,
      creator: ModelField<IAString>? = nil,
      metadata: ItemMetadata? = nil,
      d1: ModelField<IAString>? = nil,
      d2: ModelField<IAString>? = nil,
      dir: ModelField<IAString>? = nil,
      isCollection: ModelField<IABool>? = nil,
      isDark: Bool? = nil,
      itemLastUpdated: ModelField<IAEpochDate>? = nil,
      filesCount: ModelField<IAInt>? = nil,
      itemSize: ModelField<IAInt>? = nil,
      server: ModelField<IAString>? = nil,
      serversUnavailable: Bool? = nil,
      uniq: ModelField<IAInt>? = nil,
      workableServers: ModelField<IAString>? = nil,
      files: [File]? = nil,
      reviews: [Review]? = nil
    ) {
      self.alternateLocations = alternateLocations
      self.created = created
      self.collection = collection
      self.creator = creator
      self.metadata = metadata
      self.d1 = d1
      self.d2 = d2
      self.dir = dir
      self.isCollection = isCollection
      self.isDark = isDark
      self.itemLastUpdated = itemLastUpdated
      self.filesCount = filesCount
      self.itemSize = itemSize
      self.server = server
      self.serversUnavailable = serversUnavailable
      self.uniq = uniq
      self.workableServers = workableServers
      self.files = files
      self.reviews = reviews
    }
  }
}
