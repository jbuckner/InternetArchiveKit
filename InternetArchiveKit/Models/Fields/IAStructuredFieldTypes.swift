//
//  IAStructuredFieldTypes.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /// A timestamp the Archive counts in seconds since 1970, as `created` and `mtime` are.
  ///
  /// Wraps the `Date` rather than being one so that encoding stays independent of the
  /// encoder's `dateEncodingStrategy`. A bare `Date` would be written by whatever strategy
  /// the caller set: the default writes seconds since 2001, which reads back through an
  /// epoch parser as a date 31 years off, and `.iso8601` writes a string no epoch parser
  /// accepts at all. Encoding the number directly means the value survives either way.
  public struct EpochDate: Codable, Sendable, Hashable, Comparable, CustomStringConvertible {
    public let date: Date

    public var timeIntervalSince1970: TimeInterval { date.timeIntervalSince1970 }

    public init(date: Date) {
      self.date = date
    }

    public init(timeIntervalSince1970 seconds: TimeInterval) {
      self.date = Date(timeIntervalSince1970: seconds)
    }

    public init?(wireFormat: String) {
      guard let seconds = TimeInterval(wireFormat.trimmingCharacters(in: .whitespaces)) else {
        return nil
      }
      self.init(timeIntervalSince1970: seconds)
    }

    public var description: String { "\(date)" }

    public static func < (lhs: EpochDate, rhs: EpochDate) -> Bool { lhs.date < rhs.date }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let seconds = try? container.decode(TimeInterval.self) {
        self.init(timeIntervalSince1970: seconds)
        return
      }
      let raw = try container.decode(String.self)
      guard let parsed = EpochDate(wireFormat: raw) else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "\(raw) is not a number of seconds since 1970")
      }
      self = parsed
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(timeIntervalSince1970)
    }
  }

  /**
   Internet Archive epoch timestamp field, for fields counted in seconds since 1970.

   Separate from `IADate` on purpose. `IADate` accepts a bare year like `"2018"`, which would be
   a nonsense epoch, so the two parsers can't be merged without one corrupting the other.

   ### Example Usage
   ```
   let field = IAEpochDate(fromString: "1581697658")
   field.value?.date => Date "2020-02-14T15:07:38Z"
   ```
   */
  public class IAEpochDate: ModelFieldProtocol {
    public typealias FieldType = EpochDate
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = EpochDate(wireFormat: string)
    }
    /// The Archive sends these as JSON numbers on an item and as strings on a file, so both
    /// are accepted. A non-string, non-number value rethrows, letting `ModelField` try its
    /// array path; only a string that won't parse yields a `nil` value.
    required public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let seconds = try? container.decode(TimeInterval.self) {
        self.value = EpochDate(timeIntervalSince1970: seconds)
      } else {
        self.value = EpochDate(wireFormat: try container.decode(String.self))
      }
    }
  }

  /// The width-to-height ratio of a video, as written in an item's `aspect_ratio` field.
  ///
  /// Encodes back to the `"16:9"` string it was parsed from, so an encoded item stays the
  /// shape the Archive serves and decodes again without special handling.
  public struct AspectRatio: Codable, Sendable, Hashable, CustomStringConvertible {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
      self.width = width
      self.height = height
    }

    public init?(wireFormat: String) {
      let parts = wireFormat.split(separator: ":", omittingEmptySubsequences: false)
      guard parts.count == 2,
        let width = Int(parts[0].trimmingCharacters(in: .whitespaces)),
        let height = Int(parts[1].trimmingCharacters(in: .whitespaces))
      else { return nil }
      self.init(width: width, height: height)
    }

    /// Width divided by height, or `nil` for a zero height
    public var ratio: Double? {
      guard height != 0 else { return nil }
      return Double(width) / Double(height)
    }

    public var description: String { "\(width):\(height)" }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let raw = try container.decode(String.self)
      guard let parsed = AspectRatio(wireFormat: raw) else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "\(raw) is not a width:height ratio")
      }
      self = parsed
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(description)
    }
  }

  /**
   Internet Archive `aspect_ratio` field.

   Needs its own type rather than reusing `IATimeInterval`, which would read the colon as a
   time separator and turn `"16:9"` into 969 seconds.

   ### Example Usage
   ```
   let field = IAAspectRatio(fromString: "16:9")
   field.value?.width => 16
   field.value?.ratio => 1.777...
   ```
   */
  public class IAAspectRatio: ModelFieldProtocol {
    public typealias FieldType = AspectRatio
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = AspectRatio(wireFormat: string)
    }
    /// Decodes the string and parses it. A non-string value (an array, for a repeatable
    /// field) rethrows on purpose, so `ModelField` falls through to its array path; only a
    /// string that won't parse yields a `nil` value.
    required public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.value = FieldType(wireFormat: try container.decode(String.self))
    }
  }

  /// The curation record on an item, describing who last changed its visibility and when.
  ///
  /// Encodes back to the bracketed form the Archive writes, so it round-trips through a cache.
  public struct Curation: Codable, Sendable, Hashable, CustomStringConvertible {
    public let curator: String?
    public let date: Date?
    public let state: IAEnumValue<CurationState>?
    public let comment: String?

    public init(
      curator: String? = nil,
      date: Date? = nil,
      state: IAEnumValue<CurationState>? = nil,
      comment: String? = nil
    ) {
      self.curator = curator
      self.date = date
      self.state = state
      self.comment = comment
    }

    // `[tag]value[/tag]`, with the value matched lazily so a `[` inside it doesn't end the match
    private static let tagPattern = try? NSRegularExpression(
      pattern: "\\[([a-zA-Z_]+)\\](.*?)\\[/\\1\\]",
      options: [.dotMatchesLineSeparators]
    )

    /// Curation dates are written back as `yyyyMMddHHmmss` in UTC, the form the Archive
    /// uses. Reading goes through `DateParser`, which is more forgiving.
    private static let dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyyMMddHHmmss"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      return formatter
    }()

    /// Parses `[curator]…[/curator][date]…[/date][state]…[/state][comment]…[/comment]`,
    /// returning `nil` when the string carries no recognizable tags at all.
    public init?(wireFormat: String) {
      guard let tagPattern = Self.tagPattern else { return nil }
      let range = NSRange(wireFormat.startIndex..<wireFormat.endIndex, in: wireFormat)
      var tags: [String: String] = [:]
      for match in tagPattern.matches(in: wireFormat, range: range) {
        guard let nameRange = Range(match.range(at: 1), in: wireFormat),
          let valueRange = Range(match.range(at: 2), in: wireFormat)
        else { continue }
        tags[String(wireFormat[nameRange]).lowercased()] = String(wireFormat[valueRange])
      }
      guard !tags.isEmpty else { return nil }
      self.init(
        curator: tags["curator"],
        date: tags["date"].flatMap { DateParser.shared.date(from: $0) },
        state: tags["state"].map { IAEnumValue<CurationState>(rawValue: $0) },
        comment: tags["comment"]
      )
    }

    public var description: String {
      var out = ""
      if let curator { out += "[curator]\(curator)[/curator]" }
      if let date { out += "[date]\(Self.dateFormatter.string(from: date))[/date]" }
      if let state { out += "[state]\(state.rawValue)[/state]" }
      if let comment { out += "[comment]\(comment)[/comment]" }
      return out
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let raw = try container.decode(String.self)
      guard let parsed = Curation(wireFormat: raw) else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "\(raw) has no curation tags")
      }
      self = parsed
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(description)
    }
  }

  /**
   Internet Archive `curation` field.

   The Archive writes this as a run of bracketed tags rather than structured JSON, eg
   `[curator]tracey pooh[/curator][date]20190109082229[/date][state]un-dark[/state]`.

   ### Example Usage
   ```
   let field = IACuration(fromString: "[curator]bob[/curator][state]dark[/state]")
   field.value?.curator     => "bob"
   field.value?.state       => CurationState.dark
   ```
   */
  public class IACuration: ModelFieldProtocol {
    public typealias FieldType = Curation
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = Curation(wireFormat: string)
    }
    /// Decodes the string and parses it. A non-string value (an array, for a repeatable
    /// field) rethrows on purpose, so `ModelField` falls through to its array path; only a
    /// string that won't parse yields a `nil` value.
    required public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.value = FieldType(wireFormat: try container.decode(String.self))
    }
  }

  /// A URN naming this item in some other catalog, from an item's `external-identifier` field.
  ///
  /// Encodes back to the full `urn:scheme:value` string.
  public struct ExternalIdentifier: Codable, Sendable, Hashable, CustomStringConvertible {
    /// The naming authority, eg `isbn` in `urn:isbn:0123456789`
    public let scheme: String
    /// Everything after the scheme, which may itself contain colons
    public let value: String

    public init(scheme: String, value: String) {
      self.scheme = scheme
      self.value = value
    }

    public init?(wireFormat: String) {
      // split on the first two colons only: the value keeps any of its own,
      // as in `urn:lcp:goody:epub:1cc7e3b8-…`
      let parts = wireFormat.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
      guard parts.count == 3, parts[0].lowercased() == "urn",
        !parts[1].isEmpty, !parts[2].isEmpty
      else { return nil }
      self.init(scheme: String(parts[1]), value: String(parts[2]))
    }

    public var description: String { "urn:\(scheme):\(value)" }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let raw = try container.decode(String.self)
      guard let parsed = ExternalIdentifier(wireFormat: raw) else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "\(raw) is not a urn:scheme:value identifier")
      }
      self = parsed
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(description)
    }
  }

  /**
   Internet Archive `external-identifier` field.

   ### Example Usage
   ```
   let field = IAExternalIdentifier(fromString: "urn:isbn:0123456789")
   field.value?.scheme => "isbn"
   field.value?.value  => "0123456789"
   ```
   */
  public class IAExternalIdentifier: ModelFieldProtocol {
    public typealias FieldType = ExternalIdentifier
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = ExternalIdentifier(wireFormat: string)
    }
    /// Decodes the string and parses it. A non-string value (an array, for a repeatable
    /// field) rethrows on purpose, so `ModelField` falls through to its array path; only a
    /// string that won't parse yields a `nil` value.
    required public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.value = FieldType(wireFormat: try container.decode(String.self))
    }
  }
}
