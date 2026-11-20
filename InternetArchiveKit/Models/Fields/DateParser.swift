//
//  DateFormatters.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/20/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation
import JJLISO8601DateFormatter

protocol DateParserProtocol {
  func date(from string: String) -> Date?
}

extension DateFormatter: DateParserProtocol {}
extension JJLISO8601DateFormatter: DateParserProtocol {}

/// Parses the date formats found in Internet Archive metadata.
///
/// The shared instance is safe to use from concurrent decodes: `parsers` is
/// immutable after init, and both `DateFormatter` and
/// `JJLISO8601DateFormatter` are documented thread-safe.
final class DateParser: @unchecked Sendable {
  static let shared: DateParser = DateParser()

  func date(from string: String) -> Date? {
    // An all-numeric format with no separators, like `yyyyMMdd`, matches the empty string
    // and hands back a default date of 2000-01-01. Nothing downstream can tell that apart
    // from a real parse, so reject empty input before it reaches a formatter.
    guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

    for parser in parsers {
      if let parsedDate = parser.date(from: string) {
        return parsedDate
      }
    }
    return nil
  }

  // Ordered most specific first: `DateFormatter` consumes as much as it can rather than
  // requiring a full match, so a looser format ahead of a tighter one can win with a
  // partial parse.
  private let parsers: [DateParserProtocol] = [
    JJLISO8601DateFormatter(),
    makeFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss"),
    makeFormatter(dateFormat: "yyyy-MM-dd"),
    makeFormatter(dateFormat: "yyyyMMddHHmmss"),
    makeFormatter(dateFormat: "yyyyMMdd"),
    makeFormatter(dateFormat: "yyyy-MM"),
    makeFormatter(dateFormat: "yyyy"),
    makeFormatter(dateFormat: "'['yyyy']'"),
    makeFormatter(dateFormat: "'c.a.' yyyy"),
  ]

  private static func makeFormatter(dateFormat: String) -> DateFormatter {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }
}
