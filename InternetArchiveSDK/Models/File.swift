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
    public let name: String?
    public let source: String?
    public let format: String?
    public let original: StringOrArray?
    public let title: String?
    public let creator: String?
    public let album: String?
    public let track: String?
    public let md5: String?
    public let mtime: String?
    public let size: String?
    public let crc32: String?
    public let sha1: String?
    public let length: String?
    public let height: String?
    public let width: String?
  }
}
