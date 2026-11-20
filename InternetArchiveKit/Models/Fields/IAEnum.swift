//
//  IAEnum.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

/// A controlled vocabulary from the Internet Archive metadata schema.
///
/// Conforming types are plain `String`-backed enums listing the values the schema documents.
/// They're always used through `IAEnumValue`, which is what keeps a value the Archive
/// added after this library was built from being dropped.
public protocol IAEnumCase: RawRepresentable, Codable, Sendable, Hashable, CaseIterable
where RawValue == String {}

extension InternetArchive {
  /**
   The value of a metadata field with a documented set of allowed values.

   The Archive extends its vocabularies without notice, so decoding straight into a Swift enum
   would silently discard anything unrecognized. `IAEnumValue` keeps the raw string instead, so
   `rawValue` always round-trips and `known` tells you whether it matched.

   ### Example Usage
   ```
   let value = IAEnumValue<MediaType>(rawValue: "etree")
   value.known    => MediaType.etree
   value.rawValue => "etree"

   let future = IAEnumValue<MediaType>(rawValue: "hologram")
   future.known    => nil
   future.rawValue => "hologram"
   ```

   Comparison works against the case or the raw string, so both of these read correctly:
   ```
   metadata.mediatype?.value == .etree
   metadata.mediatype?.value == "etree"
   ```
   */
  public enum IAEnumValue<T: IAEnumCase>: RawRepresentable, Codable, Sendable, Hashable {
    /// A value matching one of the documented cases
    case known(T)
    /// A value the schema doesn't document, kept verbatim
    case unknown(String)

    /// Never fails: an unrecognized string becomes `.unknown` rather than `nil`
    public init(rawValue: String) {
      if let matched = T(rawValue: rawValue) {
        self = .known(matched)
      } else {
        self = .unknown(rawValue)
      }
    }

    public var rawValue: String {
      switch self {
      case .known(let matched): return matched.rawValue
      case .unknown(let raw): return raw
      }
    }

    /// The matched case, or `nil` when the Archive sent a value this library doesn't know
    public var known: T? {
      switch self {
      case .known(let matched): return matched
      case .unknown: return nil
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.init(rawValue: try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }
  }
}

/// Compare against a documented case, so `metadata.mediatype?.value == .etree` reads naturally.
/// An `.unknown` value never matches one.
///
/// These are free functions because an operator taking an *optional* of the enclosing type can't
/// be declared as a static member, and the optional form is the one call sites actually use:
/// every model field is `ModelField<…>?` and `value` is itself optional.
public func == <T: IAEnumCase>(lhs: InternetArchive.IAEnumValue<T>?, rhs: T) -> Bool {
  lhs?.known == rhs
}

public func != <T: IAEnumCase>(lhs: InternetArchive.IAEnumValue<T>?, rhs: T) -> Bool {
  !(lhs == rhs)
}

/// Compare against the wire string, which matches `.known` and `.unknown` values alike.
public func == <T: IAEnumCase>(lhs: InternetArchive.IAEnumValue<T>?, rhs: String) -> Bool {
  lhs?.rawValue == rhs
}

public func != <T: IAEnumCase>(lhs: InternetArchive.IAEnumValue<T>?, rhs: String) -> Bool {
  !(lhs == rhs)
}

extension InternetArchive.IAEnumValue: CustomStringConvertible {
  public var description: String { rawValue }
}

extension InternetArchive {
  /**
   Internet Archive enumerated field, for schema fields with a documented set of values.

   ### Example Usage
   ```
   let mediatype = IAEnum<MediaType>(fromString: "etree")
   mediatype.value?.known => MediaType.etree
   ```
   */
  public class IAEnum<T: IAEnumCase>: ModelFieldProtocol {
    public typealias FieldType = IAEnumValue<T>
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = FieldType(rawValue: string)
    }
    required public init(from decoder: Decoder) throws {
      self.value = try FieldType(from: decoder)
    }
  }
}
