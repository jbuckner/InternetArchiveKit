//
//  File.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   An Internet Archive File

   This will be returned in the `files` property from an `InternetArchive().itemDetail()` request.
   */
  public struct File: Decodable {
    public let album: ModelField<IAString>?
    public let bitrate: ModelField<IAInt>?
    public let crc32: ModelField<IAString>?
    public let creator: ModelField<IAString>?
    public let format: ModelField<IAString>?
    public let height: ModelField<IAInt>?
    public let length: ModelField<IATimeInterval>?
    public let md5: ModelField<IAString>?
    public let mtime: ModelField<IAString>?
    public let name: ModelField<IAString>?
    public let original: ModelField<IAString>?
    public let sha1: ModelField<IAString>?
    public let size: ModelField<IAInt>?
    public let source: ModelField<IAString>?
    public let title: ModelField<IAString>?
    public let track: ModelField<IAInt>?
    public let width: ModelField<IAInt>?
  }
}
