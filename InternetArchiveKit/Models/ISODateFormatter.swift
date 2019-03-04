//
//  ISODateFormatter.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/20/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

class ISODateFormatter: ISO8601DateFormatter {
  static let shared: ISODateFormatter = ISODateFormatter()
}
