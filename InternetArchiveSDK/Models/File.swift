//
//  File.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

struct File: Decodable {
  let name: String?
  let source: String?
  let format: String?
  let original: String?
  let title: String?
  let creator: String?
  let album: String?
  let track: String?
  let md5: String?
  let mtime: String?
  let size: String?
  let crc32: String?
  let sha1: String?
  let length: String?
  let height: String?
  let width: String?
}
