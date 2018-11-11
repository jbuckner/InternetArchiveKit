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
    public let created: Int?
    public let collection: [String]?
    public let creator: String?
    public let metadata: ItemMetadata?
    public let d1: String?
    public let d2: String?
    public let dir: String?
    public let isCollection: Bool?
    public let filesCount: Int?
    public let itemSize: Int?
    public let server: String?
    public let uniq: Int?
    public let workableServers: [String]?
    public let files: [File]?
  }
}
