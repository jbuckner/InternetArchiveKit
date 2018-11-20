//
//  StringOrArray.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/12/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  // some properties from the InternetArchive can be stored as strings or an array of strings
  // this struct handles both cases and normalizes them to an array of strings
  public struct StringOrArray: Decodable {
    public let values: [String]

    public init(from decoder: Decoder) throws {

      do {
        let container = try decoder.singleValueContainer()
        let decodedString: String = try container.decode(String.self)
        self.values = [decodedString]
      } catch {
        var container = try decoder.unkeyedContainer()
        var strings: [String] = []
        while !container.isAtEnd {
          let decodedString: String = try container.decode(String.self)
          strings.append(decodedString)
        }
        self.values = strings
      }
    }
  }
}
