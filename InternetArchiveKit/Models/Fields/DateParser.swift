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

class DateParser {
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
  private lazy var parsers: [DateParserProtocol] = {
    return [isoFormatter, dateTimeFormatter, yearMonthDayFormatter, yearMonthFormatter, yearFormatter,
            yearBracketFormatter, yearCircaFormatter]
  }()

  private lazy var yearFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private lazy var yearBracketFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "'['yyyy']'"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private lazy var yearCircaFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "'c.a.' yyyy"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private lazy var yearMonthFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private lazy var yearMonthDayFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private lazy var dateTimeFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private lazy var isoFormatter: DateParserProtocol = JJLISO8601DateFormatter()
}
