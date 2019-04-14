//
//  DateFormatters.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/20/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

class DateFormatters {
  static let dateFormatter: DateFormatter = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  static let dateTimeFormatter: DateFormatter = {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  static let isoFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
}

// This is a very fast ISO8601 date parser taken from http://jordansmith.io/performant-date-parsing/
// but it doesn't have any real error checking. I just added a simple check for the letter 'T'
// If that fails, try another date parser
class FastISO8601DateParser {
  private static var calendarCache = [Int : Calendar]()
  private static var components = DateComponents()

  private static let year = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private static let month = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private static let day = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private static let hour = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private static let minute = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private static let second = UnsafeMutablePointer<Float>.allocate(capacity: 1)
  private static let hourOffset = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  private static let minuteOffset = UnsafeMutablePointer<Int>.allocate(capacity: 1)

  private static let parseQueue = DispatchQueue(label: "FastISO8601DateParseQueue")

  static func parse(_ dateString: String) -> Date? {
    guard dateString.contains("T") else { return nil }

    return FastISO8601DateParser.parseQueue.sync {
      let parseCount = withVaList([year, month, day, hour, minute,
                                   second, hourOffset, minuteOffset], { pointer in
                                    vsscanf(dateString, "%d-%d-%dT%d:%d:%f%d:%dZ", pointer)
      })

      components.year = year.pointee
      components.minute = minute.pointee
      components.day = day.pointee
      components.hour = hour.pointee
      components.month = month.pointee
      components.second = Int(second.pointee)

      // Work out the timezone offset

      if hourOffset.pointee < 0 {
        minuteOffset.pointee = -minuteOffset.pointee
      }

      let offset = parseCount <= 6 ? 0 :
        hourOffset.pointee * 3600 + minuteOffset.pointee * 60

      // Cache calendars per timezone
      // (setting it each date conversion is not performant)

      if let calendar = calendarCache[offset] {
        return calendar.date(from: components)
      }

      var calendar = Calendar(identifier: .gregorian)
      guard let timeZone = TimeZone(secondsFromGMT: offset) else { return nil }
      calendar.timeZone =  timeZone
      calendarCache[offset] = calendar
      return calendar.date(from: components)
    }
  }
}
