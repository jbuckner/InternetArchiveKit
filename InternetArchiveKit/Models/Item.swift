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
  public struct Item: Decodable {
    public let created: ModelField<IAInt>?
    public let collection: ModelField<IAString>?
    public let creator: ModelField<IAString>?
    public let metadata: ItemMetadata?
    public let d1: ModelField<IAString>? // swiftlint:disable:this identifier_name
    public let d2: ModelField<IAString>? // swiftlint:disable:this identifier_name
    public let dir: ModelField<IAString>?
    public let isCollection: ModelField<IABool>?
    public let isDark: Bool?
    public let filesCount: ModelField<IAInt>?
    public let itemSize: ModelField<IAInt>?
    public let server: ModelField<IAString>?
    public let uniq: ModelField<IAInt>?
    public let workableServers: ModelField<IAString>?
    public let files: [File]?
    public let reviews: [Review]?

    public init(created: ModelField<IAInt>? = nil,
                collection: ModelField<IAString>? = nil,
                creator: ModelField<IAString>? = nil,
                metadata: ItemMetadata? = nil,
                d1: ModelField<IAString>? = nil, // swiftlint:disable:this identifier_name
                d2: ModelField<IAString>? = nil, // swiftlint:disable:this identifier_name
                dir: ModelField<IAString>? = nil,
                isCollection: ModelField<IABool>? = nil,
                isDark: Bool? = nil,
                filesCount: ModelField<IAInt>? = nil,
                itemSize: ModelField<IAInt>? = nil,
                server: ModelField<IAString>? = nil,
                uniq: ModelField<IAInt>? = nil,
                workableServers: ModelField<IAString>? = nil,
                files: [File]? = nil,
                reviews: [Review]? = nil) {
      self.created = created
      self.collection = collection
      self.creator = creator
      self.metadata = metadata
      self.d1 = d1
      self.d2 = d2
      self.dir = dir
      self.isCollection = isCollection
      self.isDark = isDark
      self.filesCount = filesCount
      self.itemSize = itemSize
      self.server = server
      self.uniq = uniq
      self.workableServers = workableServers
      self.files = files
      self.reviews = reviews
    }
  }
}
