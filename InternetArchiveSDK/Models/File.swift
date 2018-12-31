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
    public let album: ModelField<String>?
    public let bitrate: ModelField<Int>?
    public let crc32: ModelField<String>?
    public let creator: ModelField<String>?
    public let format: ModelField<String>?
    public let height: ModelField<Int>?
    public let length: ModelField<String>?
    public let md5: ModelField<String>?
    public let mtime: ModelField<String>?
    public let name: ModelField<String>?
    public let original: ModelField<String>?
    public let sha1: ModelField<String>?
    public let size: ModelField<Int>?
    public let source: ModelField<String>?
    public let title: ModelField<String>?
    public let track: ModelField<Int>?
    public let width: ModelField<Int>?
  }
}
