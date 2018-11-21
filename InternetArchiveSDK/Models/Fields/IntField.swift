//
//  IntField.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/20/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public struct IntField: Decodable {
    public let value: Int?
    public let rawValue: String?

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let decodedString: String = try container.decode(String.self)
      self.rawValue = decodedString
      self.value = Int(decodedString)
    }
  }
}
