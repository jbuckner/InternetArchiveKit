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
final class DateParser {
  static let shared: DateParser = DateParser()

  func date(from string: String) -> Date? {
    for parser in parsers {
      if let parsedDate = parser.date(from: string) {
        return parsedDate
      }
    }
    return nil
  }

  // the parsers to try in order of priority
  private let parsers: [DateParserProtocol] = [
    JJLISO8601DateFormatter(),
    makeFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss"),
    makeFormatter(dateFormat: "yyyy-MM-dd"),
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
