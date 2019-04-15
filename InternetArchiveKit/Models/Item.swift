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
    public let d1: ModelField<IAString>?
    public let d2: ModelField<IAString>?
    public let dir: ModelField<IAString>?
    public let isCollection: ModelField<IABool>?
    public let isDark: Bool?
    public let filesCount: ModelField<IAInt>?
    public let itemSize: ModelField<IAInt>?
    public let server: ModelField<IAString>?
    public let uniq: ModelField<IAInt>?
    public let workableServers: ModelField<IAString>?
    public let files: [File]?
  }
}
