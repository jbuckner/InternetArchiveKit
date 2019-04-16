//
//  FastISO8601DateParser.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 4/15/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import Foundation

/**
 A very fast ISO8601 date parser

 This is a very fast ISO8601 date parser derived from [this blog post](http://jordansmith.io/performant-date-parsing/)
 by Jordan Smith. Only use this for the basic ISO8601 GMT format: `yyyy-MM-ddTHH:mm:ssZ`.

 **Warning**

 Don't use this unless you are sure your dates are in basic ISO8601 GMT format: `yyyy-MM-ddTHH:mm:ssZ`.
 If you are unsure, use Apple's `ISO8601DateFormatter` instead.

 Its speed comes from use of the the low-level `vsscanf` function and minimal error checking.

 ### Suggestion

 Use a singleton instance of this to maintain top performance. It is thread-safe.

 ### Example Usage

 ```
 let parser = FastISO8601GMTDateParser()
 parser.date(from: "2018-11-15T15:23:11Z")
 => Date object ("2018-11-15T15:23:11Z")
 ```
 */
internal class FastISO8601GMTDateParser: DateParserProtocol {
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
      dateString.count == 20,
      dateString[dateString.index(dateString.startIndex, offsetBy: 10)] == "T",
      dateString[dateString.index(dateString.startIndex, offsetBy: 19)] == "Z"
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
