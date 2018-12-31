//
//  ModelField.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 12/24/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

// This protocol allows us to convert strings to scalar values through
// a common initializer. If we need to add additional metadata field type converters,
// we just have to provide the new type with an `init?(string: String)` initializer
public protocol StringParsable {
  init?(string: String)
}

extension Int: StringParsable {
  public init?(string: String) {
    self.init(string)
  }
}

extension String: StringParsable {
  public init?(string: String) {
    self.init(string)
  }
}

extension Double: StringParsable {
  public init?(string: String) {
    self.init(string)
  }
}

extension Bool: StringParsable {
  public init?(string: String) {
    self.init(string)
  }
}

extension URL: StringParsable {
  public init?(string: String) {
    self.init(string: string, relativeTo: nil)
  }
}

extension Date: StringParsable {
  public init?(string: String) {

    // try parsing date (yyyy-mm-dd), datetime (yyyy-mm-dd hh:mm:ss), or ISO8601 format
    let date: Date? = DateFormatters.dateFormatter.date(from: string) ??
                      DateFormatters.dateTimeFormatter.date(from: string) ??
                      DateFormatters.isoFormatter.date(from: string)

    if let timeInterval: TimeInterval = date?.timeIntervalSinceReferenceDate {
      self.init(timeIntervalSinceReferenceDate: timeInterval)
    } else {
      return nil
    }
  }
}

extension InternetArchive {
  // InternetArchive metadata fields are mostly stored in strings, but sometimes stored as an array of strings
  // if there are multiple values. We tend to want a casted version of the metadata, ie Int, Date, etc
  // so this MetadataField handles these cases:
  // - it normalizes the response to an array of strings
  // - it converts them to the specified type
  // - as a convenience, since _most_ fields are a single value, there is a convenience `value` accessor to get the
  //   first value returned, which will usually be the only value
  public struct ModelField<T>: Decodable where T: Decodable, T: StringParsable {
    public var value: T? { return self.values.first }
    public var values: [T] = []

    public init(from decoder: Decoder) throws {

      // first try decoding a single value, next try decoding an array of values
      do {
        if let decodedValue: T = try self.decodeSingleValue(decoder: decoder) {
          self.values = [decodedValue]
        }
      } catch {
        self.values = try self.decodeUnkeyedContainer(decoder: decoder)
      }
    }

    private func decodeSingleValue(decoder: Decoder) throws -> T? {
      let container = try decoder.singleValueContainer()
      let decodedValue: T?

      do {
        decodedValue = try container.decode(T.self)
      } catch {
        let decodedString: String = try container.decode(String.self)
        decodedValue = T(string: decodedString)
      }

      return decodedValue
    }

    private func decodeUnkeyedContainer(decoder: Decoder) throws -> [T] {
      var container = try decoder.unkeyedContainer()
      var values: [T] = []
      while !container.isAtEnd {
        let decodedValue: T?

        do {
          decodedValue = try container.decode(T.self)
        } catch {
          let decodedString: String = try container.decode(String.self)
          decodedValue = T(string: decodedString)
        }

        if let decodedValue: T = decodedValue {
          values.append(decodedValue)
        }
      }
      return values
    }
  }
}
