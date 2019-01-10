//
//  DateFormatters.swift
//  InternetArchiveSDK
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
