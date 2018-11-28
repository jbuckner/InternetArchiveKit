//
//  InternetArchiveQuery.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public struct Query: InternetArchiveURLStringProtocol {
    public var clauses: [InternetArchiveURLStringProtocol]
    public var asURLString: String { // eg `collection:(etree) AND -title:(foo)`
      let paramStrings: [String] = clauses.compactMap { $0.asURLString }
      return paramStrings.joined(separator: " AND ")
    }

    // Convenience initializer to just pass in a bunch of key:values. Only handles boolean AND cases
    public init(clauses: [String: String]) {
      let params: [QueryClause] = clauses.compactMap { (param: (field: String, value: String)) -> QueryClause? in
        return QueryClause(field: param.field, value: param.value)
      }
      self.init(clauses: params)
    }

    public init(clauses: [InternetArchiveURLStringProtocol]) {
      self.clauses = clauses
    }
  }

  public struct QueryClause: InternetArchiveURLStringProtocol {
    public let field: String
    public let value: String
    public let booleanOperator: BooleanOperator
    public var asURLString: String { // eg `collection:(etree)`, `-title:(foo)`, `(bar)`
      let urlKey: String = field.count > 0 ? "\(field):" : ""
      return "\(booleanOperator.rawValue)\(urlKey)(\(value))"
    }

    // field can be empty if you just want to search
    public init(field: String, value: String, booleanOperator: BooleanOperator = .and) {
      self.field = field
      self.value = value
      self.booleanOperator = booleanOperator
    }
  }

  public struct QueryDateRange: InternetArchiveURLStringProtocol {
    public let queryField: String
    public let dateRange: DateInterval
    public var asURLString: String { // eg `date:[2018-01-01 TO 2018-04-01]`
      let startDate: Date = dateRange.start
      let endDate: Date = dateRange.end
      let dateFormatter: DateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDateString: String = dateFormatter.string(from: startDate)
      let endDateString: String = dateFormatter.string(from: endDate)
      return "\(queryField):[\(startDateString) TO \(endDateString)]"
    }
  }

  public enum BooleanOperator: String {
    case and = ""
    case not = "-" // if we want negate this query clause, put a minus before it, ie: `-collection:(foo)`
  }
}

// MARK: Query Result Sorting
extension InternetArchive {
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
