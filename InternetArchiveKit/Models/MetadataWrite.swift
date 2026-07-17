//
//  MetadataWrite.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   One RFC 6902 JSON Patch operation for a `modifyMetadata()` call.

   Paths are JSON Pointers relative to the target, e.g. `/venue` for the
   venue field of an item's metadata.

   ### Example Usage:
   ```
   let patch: [InternetArchive.MetadataPatchOperation] = [
     .replace(path: "/venue", value: .string("Red Rocks")),
     .add(path: "/subject", value: .strings(["Live concert", "SBD"])),
     .remove(path: "/notes"),
   ]
   ```
   */
  public enum MetadataPatchOperation: Sendable, Encodable {
    case add(path: String, value: MetadataPatchValue)
    case replace(path: String, value: MetadataPatchValue)
    case remove(path: String)

    enum CodingKeys: String, CodingKey {
      case op
      case path
      case value
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .add(let path, let value):
        try container.encode("add", forKey: .op)
        try container.encode(path, forKey: .path)
        try container.encode(value, forKey: .value)
      case .replace(let path, let value):
        try container.encode("replace", forKey: .op)
        try container.encode(path, forKey: .path)
        try container.encode(value, forKey: .value)
      case .remove(let path):
        try container.encode("remove", forKey: .op)
        try container.encode(path, forKey: .path)
      }
    }
  }

  /// A metadata value in a patch: a single string or a list of strings, the
  /// two shapes Internet Archive metadata fields take.
  public enum MetadataPatchValue: Sendable, Encodable {
    case string(String)
    case strings([String])

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .string(let value):
        try container.encode(value)
      case .strings(let values):
        try container.encode(values)
      }
    }
  }

  /**
   The result of a successful `modifyMetadata()` call.

   The write is queued as a catalog task; `taskId` and `log` point at it.
   */
  public struct MetadataWriteResult: Sendable {
    public let taskId: Int?
    public let log: String?

    public init(taskId: Int?, log: String?) {
      self.taskId = taskId
      self.log = log
    }
  }

  /// The metadata write response envelope, e.g.
  /// `{"success": true, "task_id": 123, "log": "…"}` or
  /// `{"success": false, "error": "…"}`.
  struct MetadataWriteEnvelope: Decodable {
    let success: Bool?
    let taskId: Int?
    let log: String?
    let error: String?
  }
}
