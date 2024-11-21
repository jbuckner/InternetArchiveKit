//
//  ModelFieldTypes.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 4/15/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   Internet Archive `Int` field

   ### Example Usage
   ```
   let intField = IAInt(fromString: "3")
   intField.value => 3
   ```
   */
  public class IAInt: ModelFieldProtocol {
    public typealias FieldType = Int // swiftlint:disable:this nesting
    public var value: FieldType?
    required public init?(fromString string: String) {
      self.value = FieldType.init(string)
    }
    required public init(from: Decoder) throws {
      self.value = try FieldType.init(from: from)
    }
  }

  /**
   Internet Archive byte field

   ### Example Usage
   ```
   let intField = IAInt(fromString: "3")
   intField.value => 3
   ```
   */
  public class IAByte: ModelFieldProtocol {
    public typealias FieldType = Int // swiftlint:disable:this nesting
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

   ### Example Usage
   ```
   let stringField = IAInt(fromString: "Foo")
   stringField.value => "Foo"
   ```
   */
  public class IAString: ModelFieldProtocol {
    public typealias FieldType = String // swiftlint:disable:this nesting
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

   ### Example Usage
   ```
   let doubleField = IADouble(fromString: "13.54")
   doubleField.value => 13.54
   ```
   */
  public class IADouble: ModelFieldProtocol {
    public typealias FieldType = Double // swiftlint:disable:this nesting
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

   ### Example Usage
   ```
   let boolField = IABool(fromString: "true")
   boolField.value => true
   ```
   */
  public class IABool: ModelFieldProtocol {
    public typealias FieldType = Bool // swiftlint:disable:this nesting
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

   ### Example Usage
   ```
   let urlField = IAURL(fromString: "https://archive.org")
   urlField.value => URL "https://archive.org"
   ```
   */
  public class IAURL: ModelFieldProtocol {
    public typealias FieldType = URL // swiftlint:disable:this nesting
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

   Parses the following formats:
   - ISO8601 (`2018-11-15T08:23:41Z`, `2018-11-15T08:23:41-07:00`, etc)
   - Date Time (`2018-03-25 14:51:24`)
   - Date (`2018-09-03`)
   - Year (`2018`)
   - Year Month (`2018-09`)
   - Approximate Year (`[2018]`)
   - Circa Year (`c.a. 2018`)

   **Note:** The "approximate" and "circa" formats do not have a representation that they're approximate,
   since the `Date` type has no way of representing it.

   ### Example Usage
   ```
   let dateField = IADate(fromString: "2018-11-15T08:23:41Z")
   dateField.value => Date "2018-11-15T08:23:41Z"
   ```
   */
  public class IADate: ModelFieldProtocol {
    public typealias FieldType = Date // swiftlint:disable:this nesting
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
      return DateParser.shared.date(from: string)
    }
  }

  /**
   Internet Archive `TimeInterval` field. Used for fields like `length` of an audio file.

   Parses the following formats:
   - Seconds.Milliseconds (`323.4`)
   - Duration (`5:23.4`)

   ### Example Usage
   ```
   let timeIntervalField1 = IATimeInterval(fromString: "12:37.4")
   timeIntervalField1.value => TimeInterval 757.4

   let timeIntervalField2 = IATimeInterval(fromString: "526.7")
   timeIntervalField2.value => TimeInterval 526.7
   ```
   */
  public class IATimeInterval: ModelFieldProtocol {
    public typealias FieldType = TimeInterval // swiftlint:disable:this nesting
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
