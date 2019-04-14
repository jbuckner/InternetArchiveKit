//
//  ModelField.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 12/24/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

// This protocol allows us to convert strings to scalar values through
// a common initializer. If we need to add additional metadata field type converters,
// we just have to provide the new type with an `init?(string: String)` initializer
public protocol ModelFieldProtocol: Decodable {
  associatedtype FieldType: Decodable
  init?(fromString string: String)
  var value: FieldType? { get }
}

extension InternetArchive {
  public class IAInt: ModelFieldProtocol {
    public typealias FieldType = Int
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = FieldType.init(string)
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
  }

  public class IAString: ModelFieldProtocol {
    public typealias FieldType = String
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = string
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
  }

  public class IADouble: ModelFieldProtocol {
    public typealias FieldType = Double
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = FieldType.init(string)
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
  }

  public class IABool: ModelFieldProtocol {
    public typealias FieldType = Bool
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = FieldType.init(string)
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
  }

  public class IAURL: ModelFieldProtocol {
    public typealias FieldType = URL
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = FieldType.init(string: string)
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
  }

  public class IADate: ModelFieldProtocol {
    public typealias FieldType = Date
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = parseString(string: string)
    }
    required public init(from: Decoder) throws {
      let container = try from.singleValueContainer()
      let stringValue = try container.decode(String.self)
      self.value = parseString(string: stringValue)
    }
    private func parseString(string: String) -> Date? {
      // try parsing ISO8601, date (yyyy-mm-dd), or datetime (yyyy-mm-dd hh:mm:ss) format
      let date: Date? =
        DateFormatters.isoFormatter.date(from: string) ??
        DateFormatters.dateFormatter.date(from: string) ??
        DateFormatters.dateTimeFormatter.date(from: string)

      if let timeInterval: TimeInterval = date?.timeIntervalSinceReferenceDate {
        return Date.init(timeIntervalSinceReferenceDate: timeInterval)
      } else {
        return nil
      }
    }
  }

  public class IATimeInterval: ModelFieldProtocol {
    public typealias FieldType = TimeInterval
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = parseString(string: string)
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
    private func parseString(string: String) -> TimeInterval? {
      if let timeInterval: TimeInterval = TimeInterval.init(string) {
        return timeInterval
      }

      let componentArray: [String] = string.components(separatedBy: ":")
      let componentCount: Int = componentArray.count
      let seconds: Double = componentArray.enumerated().compactMap({ (offset: Int, element: String) -> Double? in
        guard let componentValue: Double = Double(element) else { return nil }
        let exponent: Int = (componentCount - 1) - offset
        let multiplier: Decimal = pow(60, exponent)
        return componentValue * Double(truncating: multiplier as NSNumber)
      }).reduce(0) { $0 + $1 }
      return seconds
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
  public struct ModelField<T>: Decodable where T: ModelFieldProtocol {
    public var value: T.FieldType? { return self.values.first }
    public var values: [T.FieldType] = []

    public init(from decoder: Decoder) throws {

      // first try decoding a single value, next try decoding an array of values
      do {
        if let decodedValue: T = try self.decodeSingleValue(decoder: decoder),
          let value: T.FieldType = decodedValue.value {
          self.values = [value]
        }
      } catch {
        self.values = try self.decodeUnkeyedContainer(decoder: decoder).compactMap({ $0.value })
      }
    }

    private func decodeSingleValue(decoder: Decoder) throws -> T? {
      let container = try decoder.singleValueContainer()
      let decodedValue: T?

      do {
        decodedValue = try container.decode(T.self)
      } catch {
        let decodedString: String = try container.decode(String.self)
        decodedValue = T(fromString: decodedString)
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
          decodedValue = T(fromString: decodedString)
        }

        if let decodedValue: T = decodedValue {
          values.append(decodedValue)
        }
      }
      return values
    }
  }
}
