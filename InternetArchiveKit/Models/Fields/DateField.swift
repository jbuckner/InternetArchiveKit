//
//  DateField.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/20/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  // dates are returned as strings so this decodes it into a `value` property
  public struct ISODateField: Decodable {
    public let value: Date?
    public let rawValue: String?

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let decodedDateString: String = try container.decode(String.self)
      self.rawValue = decodedDateString
      self.value = ISODateFormatter.shared.date(from: decodedDateString)
    }
  }
}
