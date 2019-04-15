//
//  DateFormatters.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/20/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

protocol DateParserProtocol {
  func date(from string: String) -> Date?
}

extension DateFormatter: DateParserProtocol {}
extension ISO8601DateFormatter: DateParserProtocol {}

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
    return [fastIsoFormatter, dateTimeFormatter, yearMonthDayFormatter, yearMonthFormatter, yearFormatter,
            yearBracketFormatter, yearCircaFormatter, isoFormatter]
  }()

  private let yearFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private let yearBracketFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "'['yyyy']'"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private let yearCircaFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "'c.a.' yyyy"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private let yearMonthFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private let yearMonthDayFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private let dateTimeFormatter: DateParserProtocol = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  private let isoFormatter: DateParserProtocol = ISO8601DateFormatter()

  private let fastIsoFormatter: DateParserProtocol = FastGMTISO8601DateParser()
}

// This is a very fast ISO8601 date parser derived from http://jordansmith.io/performant-date-parsing/
// I was having a lot of crashes parsing time zone offsets so I removed support for that and just left GMT
// parsing, which handles most of the cases I've seen in the Internet Archive response.
// The DateParser class falls back to the slower ISO8601DateFormatter if it's anything but GMT
private class FastGMTISO8601DateParser: DateParserProtocol {
  private var components = DateComponents()

  private let year = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private let month = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private let day = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private let hour = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private let minute = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private let second = UnsafeMutablePointer<Int>.allocate(capacity: 1)

  private lazy var gmtCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    if let timeZone = TimeZone(secondsFromGMT: 0) {
      calendar.timeZone = timeZone
    }
    return calendar
  }()

  private let parseQueue = DispatchQueue(label: "FastISO8601DateParseQueue")

  func date(from dateString: String) -> Date? {
    guard
      dateString.contains("T"),
      dateString.contains("Z"),
      dateString.count == 20
    else { return nil }

    return parseQueue.sync {
      _ = withVaList([year, month, day, hour, minute, second], { pointer in
        vsscanf(dateString, "%d-%d-%dT%d:%d:%dZ", pointer)
      })

      components.year = year.pointee
      components.minute = minute.pointee
      components.day = day.pointee
      components.hour = hour.pointee
      components.month = month.pointee
      components.second = second.pointee

      return gmtCalendar.date(from: components)
    }
  }
}
