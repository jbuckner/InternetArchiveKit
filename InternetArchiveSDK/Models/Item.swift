//
//  Item.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public struct Item: Decodable {
  let created: Int?
  let collection: [String]?
  let creator: String?
  let metadata: ItemMetadata?
  let files: [File]?
  let d1: String?
  let d2: String?
  let dir: String?
  let files_count: Int?
  let item_size: Int?
  let server: String?
  let uniq: Int?
}
