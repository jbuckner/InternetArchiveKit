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

   **Note**: The properties are all type `ModelField<T>` **except** `name`, which is a `String`.
   This means you need to access all values by their `.value` or `.values` properties, except for `identifier`,
   which you can access directly.

   **Some Background**: All other fields can be a string or array of strings so we can't access them
   directly. See the `ModelField` class for a more thorough explanation.

   For example:
   ```
   let file = File(...some file...)
   file.name = "SCIRedRocksConcert.track1.mp3" // `name` is always a String, it's like the primary key for the file
   file.length.value = TimeInterval object // we want to cast all other fields to their native type
   ```

   See the Internet Archive's
   [Python API Reference](https://archive.org/services/docs/api/metadata-schema/index.html#file-metadata-schema)
   for a description of the properties.

   **Note**: This is not an exhaustive list of properties. If you need some that are missing,
   please open a pull request.
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
    public let mtime: ModelField<IAInt>?
    public let name: String
    public let original: ModelField<IAString>?
    public let sha1: ModelField<IAString>?
    public let size: ModelField<IAInt>?
    public let source: ModelField<IAString>?
    public let title: ModelField<IAString>?
    public let track: ModelField<IAInt>?
    public let width: ModelField<IAInt>?
  }
}
