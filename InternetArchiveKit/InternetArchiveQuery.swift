//
//  InternetArchiveQuery.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   The main structure for defining search queries.

   It can be created with `key: value` pairs like `["collection": "etree"]` or an array of query clauses.
   The output is a URL string, such as `"collection:(etree) AND -title:(foo)"` in `asURLString`.

   ### Basic Usage:
   ```
   // generate a query for items in the etree collection
   let query = InternetArchive.Query(clauses: ["collection": "etree"])

   // generate a query for items not in the etree collection
   let query = InternetArchive.Query(clauses: ["-collection": "etree"])

   // generate a query for any field with a value of etree
   let query = InternetArchive.Query(clauses: ["": "etree"])
   ```

   ### Sub-queries:
   ```
   let clause1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar")
   let clause2: InternetArchive.QueryClause = InternetArchive.QueryClause(
     field: "baz", value: "boop", booleanOperator: .not)
   let query: InternetArchive.Query = InternetArchive.Query(clauses: [clause1, clause2])
   let clause3: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "snip", value: "snap")
   let subQuery: InternetArchive.Query = InternetArchive.Query(clauses: [query, clause3], booleanOperator: .or)

   subQuery => "((foo:(bar) AND -baz:(boop)) OR snip:(snap))"
   ```

   ### Advanced Usage:
   ```
   let clause1 = InternetArchive.QueryClause(field: "title", value: "String Cheese", booleanOperator: .and)
   let clause2 = InternetArchive.QueryClause(field: "foo", value: "bar", booleanOperator: .not)
   let dateInterval = DateInterval(start: startDate, end: endDate)
   let dateRangeClause = InternetArchive.QueryDateRange(queryField: "date", dateRange: dateInterval)

   let query = InternetArchive.Query(clauses: [clause1, clause2, dateRangeClause, sortField])
   ```
  */
  public struct Query: InternetArchiveURLStringProtocol {
    public var clauses: [InternetArchiveURLStringProtocol]
    public var asURLString: String? { // eg `collection:(etree) AND -title:(foo)`
      guard clauses.count > 0 else { return nil }
      let paramStrings: [String] = clauses.compactMap { $0.asURLString }
      let joinedClauses = paramStrings.joined(separator: " \(booleanOperator.rawValue) ")
      let surroundedClauses = "(\(joinedClauses))"
      return surroundedClauses
    }
    public let booleanOperator: QueryBooleanOperator

    // Convenience initializer to just pass in a bunch of key:values
    public init(clauses: [String: String], booleanOperator: QueryBooleanOperator = .and) {
      let params: [QueryClause] = clauses.compactMap { (param: (field: String, value: String)) -> QueryClause? in
        return QueryClause(field: param.field, value: param.value)
      }
      self.init(clauses: params, booleanOperator: booleanOperator)
    }

    public init(clauses: [InternetArchiveURLStringProtocol], booleanOperator: QueryBooleanOperator = .and) {
      self.clauses = clauses
      self.booleanOperator = booleanOperator
    }
  }

  public enum QueryBooleanOperator: String {
    case and = "AND"
    case or = "OR" // swiftlint:disable:this identifier_name
  }

  /**
   A query clause for use in generating a `Query`.

   This is comprised of a `field`, `value`, and `booleanOperator`.
   It will generate a search clause like `collection:(etree)`.

   `field` can be empty to search any field

   ### Example Usage:
   ```
   let clause1 = InternetArchive.QueryClause(field: "foo", value: "bar", booleanOperator: .and) => foo:(var)
   let clause2 = InternetArchive.QueryClause(field: "bar", value: "foo", booleanOperator: .not) => -bar:(foo)
   let clause3 = InternetArchive.QueryClause(field: "bar", value: "foo", exactMatch: true) => bar:"foo"
   let clause4 = InternetArchive.QueryClause(field: "foo", values: ["bar", "baz"]) => foo:(bar OR baz)
   ```
   */
  public struct QueryClause: InternetArchiveURLStringProtocol {
    public let field: String
    public let values: [String]
    public let exactMatch: Bool
    public let booleanOperator: QueryClauseBooleanOperator
    public var asURLString: String? { // eg `collection:(etree)`, `-title:(foo)`, `(bar)`, `identifier:(foo OR bar)`
      let fieldKey: String = field.count > 0 ? "\(field):" : ""
      let surroundedValues = values.compactMap { (value: String) -> String? in
        if exactMatch {
          return "\"\(value)\""
        }

        let regexFixed = quoteRegexCharacters(string: value)
        return "(\(regexFixed))"
      }
      let joinedValues = surroundedValues.joined(separator: " OR ")
      let finalValue = values.count == 1 ? joinedValues : "(\(joinedValues))"
      return "\(booleanOperator.rawValue)\(fieldKey)\(finalValue)"
    }

    private let regexReplacementStrings = [":", "[", "]", "(", ")", "OR", "or", "AND", "and"]
    private func quoteRegexCharacters(string: String) -> String {
      var normalized = string
      regexReplacementStrings.forEach {
        normalized = normalized.replacingOccurrences(of: $0, with: "\"\($0)\"")
      }
      return normalized
    }

    // convenience initializer for single-values
    public init(
      field: String,
      value: String,
      booleanOperator: QueryClauseBooleanOperator = .and,
      exactMatch: Bool = false
    ) {
      self.init(
        field: field,
        values: [value],
        booleanOperator: booleanOperator,
        exactMatch: exactMatch
      )
    }

    // field can be empty if you just want to search
    public init(
      field: String,
      values: [String],
      booleanOperator: QueryClauseBooleanOperator = .and,
      exactMatch: Bool = false
    ) {
      self.field = field
      self.values = values
      self.booleanOperator = booleanOperator
      self.exactMatch = exactMatch
    }
  }

  /**
   A query clause for use in generating a date range query.

   This is comprised of a `field` and `dateRange`.
   It will return a query like `date:[2018-01-01T07:23:12Z TO 2018-04-01T17:53:34Z]`

   ### Example Usage:
   ```
   let startDate = Date(timeIntervalSince1970: 0)
   let endDate = Date()
   let dateInterval = DateInterval(start: startDate, end: endDate)
   let dateRangeClause = InternetArchive.QueryDateRange(queryField: "date", dateRange: dateInterval)
   ```
   */
  public struct QueryDateRange: InternetArchiveURLStringProtocol {
    public let queryField: String
    public let dateRange: DateInterval
    public var asURLString: String? {
      let startDate: Date = dateRange.start
      let endDate: Date = dateRange.end
      let dateFormatter: DateFormatter = DateFormatter()

      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

      let startDateString: String = dateFormatter.string(from: startDate)
      let endDateString: String = dateFormatter.string(from: endDate)

      return QueryRangeFormatter.formatRangeString(
        queryField: queryField,
        rangeStart: startDateString,
        rangeEnd: endDateString
      )
    }

    public init(queryField: String, dateRange: DateInterval) {
      self.queryField = queryField
      self.dateRange = dateRange
    }
  }

  /**
   A query clause for use in generating a number range query.

   This is comprised of a `field`, `rangeStart`, and `rangeEnd`.
   It will return a query like `downloads:[500 TO 1000]`

   ### Example Usage:
   ```
   let downloadsClause = InternetArchive.QueryNumberRange(
     queryField: "downloads", rangeStart: 500, rangeEnd: 1000
   )
   ```
   */
  public struct QueryNumberRange: InternetArchiveURLStringProtocol {
    public let queryField: String
    public let rangeStart: Double
    public let rangeEnd: Double
    public var asURLString: String? {
      let startString: String = rangeStart.truncatingRemainder(dividingBy: 1) == 0 ?
        "\(Int(rangeStart))" : "\(rangeStart)"
      let endString: String = rangeEnd.truncatingRemainder(dividingBy: 1) == 0 ?
        "\(Int(rangeEnd))" : "\(rangeEnd)"
      return QueryRangeFormatter.formatRangeString(
        queryField: queryField,
        rangeStart: startString,
        rangeEnd: endString
      )
    }

    public init(queryField: String, rangeStart: Double, rangeEnd: Double) {
      self.queryField = queryField
      self.rangeStart = rangeStart
      self.rangeEnd = rangeEnd
    }
  }

  /**
   A query clause for use in generating a string range query.

   This is comprised of a `field`, `rangeStart`, and `rangeEnd`.
   It will return a query like `licenseurl:[http://creativecommons.org/a TO http://creativecommons.org/z]`

   ### Example Usage:
   ```
   let licenseurlClause = InternetArchive.QueryNumberRange(
     queryField: "licenseurl",
     rangeStart: "http://creativecommons.org/a",
     rangeEnd: "http://creativecommons.org/z"
   )
   ```
   */
  public struct QueryStringRange: InternetArchiveURLStringProtocol {
    public let queryField: String
    public let rangeStart: String
    public let rangeEnd: String
    public var asURLString: String? {
      return QueryRangeFormatter.formatRangeString(
        queryField: queryField,
        rangeStart: "\(rangeStart)",
        rangeEnd: "\(rangeEnd)"
      )
    }

    public init(queryField: String, rangeStart: String, rangeEnd: String) {
      self.queryField = queryField
      self.rangeStart = rangeStart
      self.rangeEnd = rangeEnd
    }
  }

  private struct QueryRangeFormatter {
    static func formatRangeString(
      queryField: String,
      rangeStart: String,
      rangeEnd: String
    ) -> String {
      return "\(queryField):[\(rangeStart) TO \(rangeEnd)]"
    }
  }

  public enum QueryClauseBooleanOperator: String {
    case and = ""
    case not = "-" // if we want negate this query clause, put a minus before it, ie: `-collection:(foo)`
  }
}

// MARK: Query Result Sorting
extension InternetArchive {
  /**
   A query item for use in generating a sort field.

   This is comprised of a `field` and `direction`. `direction` is either `.asc` or `.desc`

   ### Example Usage:
   ```
   let sortField = InternetArchive.SortField(field: "date", direction: .asc)
   ```
   */
  public struct SortField: InternetArchiveURLQueryItemProtocol {
    public let field: String
    public let direction: SortDirection
    public var asQueryItem: URLQueryItem {
      return URLQueryItem(name: "sort[]", value: "\(self.field) \(self.direction)")
    }

    public init(field: String, direction: SortDirection) {
      self.field = field
      self.direction = direction
    }
  }

  public enum SortDirection: String {
    case asc
    case desc
  }
}
