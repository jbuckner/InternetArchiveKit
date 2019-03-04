//
//  StringOrArray.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  // some properties from the InternetArchive can be stored as strings or an array of strings
  // this struct handles both cases and normalizes them to an array of strings
  public struct StringOrArrayField: Decodable {
    public let value: [String]
    public let rawValue: Any?

    public init(from decoder: Decoder) throws {

      do {
        let container = try decoder.singleValueContainer()
        let decodedString: String = try container.decode(String.self)
        self.rawValue = decodedString
        self.value = [decodedString]
      } catch {
        var container = try decoder.unkeyedContainer()
        var strings: [String] = []
        while !container.isAtEnd {
          let decodedString: String = try container.decode(String.self)
          strings.append(decodedString)
        }
        self.rawValue = strings
        self.value = strings
      }
    }
  }
}
