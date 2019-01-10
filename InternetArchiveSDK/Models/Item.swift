//
//  Item.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public struct Item: Decodable {
    public let created: ModelField<Int>?
    public let collection: ModelField<String>?
    public let creator: ModelField<String>?
    public let metadata: ItemMetadata?
    public let d1: ModelField<String>?
    public let d2: ModelField<String>?
    public let dir: ModelField<String>?
    public let isCollection: ModelField<Bool>?
    public let filesCount: ModelField<Int>?
    public let itemSize: ModelField<Int>?
    public let server: ModelField<String>?
    public let uniq: ModelField<Int>?
    public let workableServers: ModelField<String>?
    public let files: [File]?
  }
}
