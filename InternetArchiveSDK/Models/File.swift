//
//  File.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public struct File: Decodable {
    public let album: String?
    public let bitrate: IntField?
    public let crc32: String?
    public let creator: String?
    public let format: String?
    public let height: IntField?
    public let length: String?
    public let md5: String?
    public let mtime: String?
    public let name: String?
    public let original: StringOrArrayField?
    public let sha1: String?
    public let size: IntField?
    public let source: String?
    public let title: String?
    public let track: IntField?
    public let width: IntField?
  }
}
