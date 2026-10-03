//
//  LenientValue.swift
//  InternetArchiveKit
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

/// A metadata value that can arrive as a string, number, bool, or an array of
/// those. Decoding never throws: a shape it doesn't understand (an object, a
/// null) becomes an empty value, so one odd field can't fail a whole item.
///
/// Use it as a property type in your own `Decodable` structs:
/// ```
/// struct Doc: Decodable, Sendable {
///   let identifier: String
///   let year: LenientValue?
/// }
/// ```
public struct LenientValue: Codable, Sendable, Hashable {
  /// Every value, rendered as a string, in the order it arrived.
  public let strings: [String]

  public init(strings: [String]) {
    self.strings = strings
  }

  public init(from decoder: Decoder) {
    guard let container = try? decoder.singleValueContainer() else {
      strings = []
      return
    }
    if let list = try? container.decode([Element].self) {
      strings = list.compactMap(\.string)
    } else if let single = try? container.decode(Element.self) {
      strings = single.string.map { [$0] } ?? []
    } else {
      strings = []
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(strings)
  }

  /// The first value that isn't blank, trimmed.
  public var first: String? {
    strings
      .lazy
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .first { !$0.isEmpty }
  }

  /// The leading four digits of `first`, so "1952", "1952-06-01" and
  /// "1952?" all give 1952.
  public var year: Int? {
    guard let text = first else { return nil }
    let digits = text.prefix(4)
    guard digits.count == 4, digits.allSatisfy(\.isASCII), digits.allSatisfy(\.isNumber)
    else { return nil }
    return Int(digits)
  }

  /// `first` as an integer. A whole-number decimal like "12.0" counts.
  public var int: Int? {
    guard let text = first else { return nil }
    if let value = Int(text) { return value }
    guard let value = Double(text), value.rounded() == value, abs(value) < 9e15
    else { return nil }
    return Int(value)
  }

  /// `first` as a double.
  public var double: Double? {
    guard let text = first, let value = Double(text), value.isFinite else { return nil }
    return value
  }

  /// `first` as a bool: "true", "yes" and "1" are true, "false", "no" and "0"
  /// are false, anything else is nil.
  public var bool: Bool? {
    switch first?.lowercased() {
    case "true", "yes", "1": return true
    case "false", "no", "0": return false
    default: return nil
    }
  }

  /// `first` as a duration in seconds. Reads plain seconds ("1740.04"),
  /// "mm:ss" and "h:mm:ss". A bare "0" is 0, not nil.
  public var seconds: TimeInterval? {
    guard let text = first else { return nil }
    let parts = text.split(separator: ":", omittingEmptySubsequences: false)
    guard (1...3).contains(parts.count) else { return nil }
    var total: TimeInterval = 0
    for (index, part) in parts.enumerated() {
      let isLast = index == parts.count - 1
      guard let value = Double(part), value.isFinite, value >= 0 else { return nil }
      // only the last component may carry a fraction
      if !isLast && value.rounded() != value { return nil }
      total = total * 60 + value
    }
    return total
  }

  private struct Element: Decodable {
    let string: String?

    init(from decoder: Decoder) {
      let container = try? decoder.singleValueContainer()
      if let text = try? container?.decode(String.self) {
        string = text
      } else if let flag = try? container?.decode(Bool.self) {
        string = flag ? "true" : "false"
      } else if let number = try? container?.decode(Int.self) {
        string = String(number)
      } else if let number = try? container?.decode(Double.self) {
        string = String(number)
      } else {
        string = nil
      }
    }
  }
}
