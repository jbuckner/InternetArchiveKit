//
//  ModelField.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 12/24/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

/// A protocol to abstract Internet Archive properties to native Swift types
///
/// This protocol allows converting different field types to more specific, native Swift types.
/// For example, the Internet Archive metadata `length` field can be represented as a `TimeInterval`
/// so an `IATimeInterval` knows how to convert "323.4" (seconds) or "5:23" (hh:mm:ss) to a `TimeInterval`
///
/// A `ModelFieldProtocol` class is instantiated with a `String` and its value accessed through the `value` property.
///
/// ### Example Usage
/// ```
/// let intField: IAInt = IAInt(string: "3")
/// intField.value => 3
/// ```
public protocol ModelFieldProtocol: Decodable {
  associatedtype FieldType: Decodable
  init?(fromString string: String)
  var value: FieldType? { get }
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
  
   Native types are wrapped in `ModelFieldProtocol` objects like `IAInt` and `IADate`
   to handle the string to native conversion.
  
   ### Example Usage:
   ```
   struct Foo: Decodable {
     let foo: ModelField<IAInt>
     let bar: ModelField<IAString>
   }
   let json: String = "{ \"foo\": \"3\", \"bar\": [\"boop\", \"bop\"] }"
   let data = json.data(using: .utf8)!
   let results: Foo = try! JSONDecoder().decode(Foo.self, from: data)
   results.foo.values => [3]
   results.foo.value => 3
   results.bar.values => ["boop", "bop"]
   results.bar.value => "boop"
   ```
   */
  public struct ModelField<T>: Decodable where T: ModelFieldProtocol {
    /// A convenience accessor for the first value of the `values` array
    public var value: T.FieldType? { return self.values.first }
    /// An array of values of type `T`
    public var values: [T.FieldType] = []

    public init(values: [T.FieldType]) {
      self.values = values
    }

    public init(from decoder: Decoder) throws {

      // first try decoding a single value, next try decoding an array of values
      do {
        if let decodedValue: T = try self.decodeSingleValue(decoder: decoder),
          let value: T.FieldType = decodedValue.value
        {
          self.values = [value]
        }
      } catch {
        self.values = try self.decodeUnkeyedContainer(decoder: decoder)
          .compactMap({ $0.value })
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
