//
//  ModelField.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 12/24/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

/**
 A protocol to abstract Internet Archive properties to native Swift types

 This protocol allows converting different field types to more specific, native Swift types.
 For example, the Internet Archive metadata `length` field can be represented as a `TimeInterval`
 so an `IATimeInterval` knows how to convert "323.4" (seconds) or "5:23" (hh:mm:ss) to a `TimeInterval`

 A `ModelFieldProtocol` class is instantiated with a `String` and its value accessed through the `value` property.

 # Example Usage
 ```
 let intField: IAInt = IAInt(string: "3")
 intField.value => 3
 ```
 */
public protocol ModelFieldProtocol: Decodable {
  associatedtype FieldType: Decodable
  init?(fromString string: String)
  var value: FieldType? { get }
}

extension InternetArchive {
  /**
   Internet Archive `Int` field

   Conforms to `ModelFieldProtocol`

   # Example Usage
   ```
   let intField = IAInt(fromString: "3")
   intField.value => 3
   ```
   */
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

  /**
   Internet Archive `String` field

   Conforms to `ModelFieldProtocol`

   # Example Usage
   ```
   let stringField = IAInt(fromString: "Foo")
   stringField.value => "Foo"
   ```
   */
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

  /**
   Internet Archive `Double` field

   Conforms to `ModelFieldProtocol`

   # Example Usage
   ```
   let doubleField = IADouble(fromString: "13.54")
   doubleField.value => 13.54
   ```
   */
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

  /**
   Internet Archive `Bool` field

   Conforms to `ModelFieldProtocol`

   # Example Usage
   ```
   let boolField = IABool(fromString: "true")
   boolField.value => true
   ```
   */
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

  /**
   Internet Archive `URL` field

   Conforms to `ModelFieldProtocol`

   # Example Usage
   ```
   let urlField = IAURL(fromString: "https://archive.org")
   urlField.value => URL "https://archive.org"
   ```
   */
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

  /**
   Internet Archive `Date` field

   Conforms to `ModelFieldProtocol`.

   Parses the following formats:
   - ISO8601 (`2018-11-15T08:23:41Z`)
   - Date Time (`2018-03-25 14:51:24`)
   - Date (`2018-09-03`)

   # Example Usage
   ```
   let dateField = IADate(fromString: "2018-11-15T08:23:41Z")
   dateField.value => Date "2018-11-15T08:23:41Z"
   ```
   */
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
      let date: Date? =
        FastISO8601DateParser.parse(string) ??
        DateFormatters.dateFormatter.date(from: string) ??
        DateFormatters.dateTimeFormatter.date(from: string) ??
        DateFormatters.isoFormatter.date(from: string) // fallback to the "real" (slower) ISOFormatter as a final check

      if let timeInterval: TimeInterval = date?.timeIntervalSinceReferenceDate {
        return Date.init(timeIntervalSinceReferenceDate: timeInterval)
      } else {
        return nil
      }
    }
  }

  /**
   Internet Archive `TimeInterval` field. Used for fields like `length` of an audio file.

   Conforms to `ModelFieldProtocol`.

   Parses the following formats:
   - Seconds.Milliseconds (`323.4`)
   - Duration (`5:23.4`)

   # Example Usage
   ```
   let timeIntervalField1 = IATimeInterval(fromString: "12:37.4")
   timeIntervalField1.value => TimeInterval 757.4

   let timeIntervalField2 = IATimeInterval(fromString: "526.7")
   timeIntervalField2.value => TimeInterval 526.7
   ```
   */
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
  /**
   An abstraction for Internet Archive-style metadata fields.

   Internet Archive metadata fields can be stored as strings or an array of strings.
   Typically we want to use these fields in a native types (`Int`, `Double`, `Date`, `URL`, etc).
   The `ModelField` struct does a few things to make handling these values more convenient:
   - Provides a generic interface to any native type that is parsable from a string
   - Converts the fields from strings to their native type
   - Normalizes the response to an array of objects
   - Provides a convenience `value` accessor to get the first value of the array since most fields are single values

   # Example Usage:
   ```
   struct Foo: Decodable {
     let foo: ModelField<Int>
     let bar: ModelField<String>
   }
   let json: String = "{ \"foo\": \"3\", \"bar\": ["boop", "bop"] }"
   let data = json.data(using: .utf8)!
   let results: Foo = try! JSONDecoder().decode(Foo.self, from: data)
   results.foo.values => [3]
   results.bar.values => ["boop", "bop"]
   ```
   */
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
