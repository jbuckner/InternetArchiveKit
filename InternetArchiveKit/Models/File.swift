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

   `source` and `format` have documented value sets, so they compare against a case or the
   raw string:
   ```
   file.source?.value == .original
   file.format?.value == .vbrMP3
   file.format?.value == "VBR MP3"
   ```

   See the Internet Archive's
   [metadata schema](https://archive.org/developers/metadata-schema/index.html)
   for a description of the properties.

   **Note**: This is not an exhaustive list of properties. If you need some that are missing,
   please open a pull request.
   */
  public struct File: Codable, Sendable {
    public let name: String
    public let album: ModelField<IAString>?
    public let bitrate: ModelField<IAInt>?
    public let btih: ModelField<IAString>?
    public let crc32: ModelField<IAString>?
    public let creator: ModelField<IAString>?
    public let externalIdentifier: ModelField<IAExternalIdentifier>?
    public let filecount: ModelField<IAInt>?
    public let format: ModelField<IAEnum<FileFormat>>?
    public let height: ModelField<IAInt>?
    public let length: ModelField<IATimeInterval>?
    public let md5: ModelField<IAString>?
    public let mtime: ModelField<IAEpochDate>?
    public let original: ModelField<IAString>?
    public let `private`: ModelField<IABool>?
    public let rotation: ModelField<IAInt>?
    public let sha1: ModelField<IAString>?
    public let size: ModelField<IAInt>?
    public let source: ModelField<IAEnum<FileSource>>?
    public let summation: ModelField<IAString>?
    public let title: ModelField<IAString>?
    public let track: ModelField<IAInt>?
    public let viruscheck: ModelField<IAEpochDate>?
    public let width: ModelField<IAInt>?

    /// Spelled out because the decoder's `.convertFromSnakeCase` strategy only rewrites
    /// underscores, so `external-identifier` would never match a synthesized key.
    enum CodingKeys: String, CodingKey {
      case name
      case album
      case bitrate
      case btih
      case crc32
      case creator
      case externalIdentifier = "external-identifier"
      case filecount
      case format
      case height
      case length
      case md5
      case mtime
      case original
      case `private`
      case rotation
      case sha1
      case size
      case source
      case summation
      case title
      case track
      case viruscheck
      case width
    }

    /// Everything but `name` defaults to `nil`. Declared in the struct body on purpose:
    /// moving it to an extension would leave Swift synthesizing a memberwise init with
    /// this exact signature, which is a redeclaration.
    public init(
      name: String,
      album: ModelField<IAString>? = nil,
      bitrate: ModelField<IAInt>? = nil,
      btih: ModelField<IAString>? = nil,
      crc32: ModelField<IAString>? = nil,
      creator: ModelField<IAString>? = nil,
      externalIdentifier: ModelField<IAExternalIdentifier>? = nil,
      filecount: ModelField<IAInt>? = nil,
      format: ModelField<IAEnum<FileFormat>>? = nil,
      height: ModelField<IAInt>? = nil,
      length: ModelField<IATimeInterval>? = nil,
      md5: ModelField<IAString>? = nil,
      mtime: ModelField<IAEpochDate>? = nil,
      original: ModelField<IAString>? = nil,
      private: ModelField<IABool>? = nil,
      rotation: ModelField<IAInt>? = nil,
      sha1: ModelField<IAString>? = nil,
      size: ModelField<IAInt>? = nil,
      source: ModelField<IAEnum<FileSource>>? = nil,
      summation: ModelField<IAString>? = nil,
      title: ModelField<IAString>? = nil,
      track: ModelField<IAInt>? = nil,
      viruscheck: ModelField<IAEpochDate>? = nil,
      width: ModelField<IAInt>? = nil
    ) {
      self.name = name
      self.album = album
      self.bitrate = bitrate
      self.btih = btih
      self.crc32 = crc32
      self.creator = creator
      self.externalIdentifier = externalIdentifier
      self.filecount = filecount
      self.format = format
      self.height = height
      self.length = length
      self.md5 = md5
      self.mtime = mtime
      self.original = original
      self.`private` = `private`
      self.rotation = rotation
      self.sha1 = sha1
      self.size = size
      self.source = source
      self.summation = summation
      self.title = title
      self.track = track
      self.viruscheck = viruscheck
      self.width = width
    }
  }
}
