//
//  APIController.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/7/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public protocol InternetArchiveAPIControllerProtocol {
  func generateSearchUrl(query: InternetArchiveAPIURLStringProtocol,
                         start: Int,
                         rows: Int,
                         fields: [String],
                         sortFields: [InternetArchiveAPIURLQueryItemProtocol],
                         additionalQueryParams: [URLQueryItem]) -> URL?
  func generateMetadataUrl(identifier: String) -> URL?
  func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL?
}

public protocol InternetArchiveAPIURLStringProtocol {
  var asURLString: String { get }
}

public protocol InternetArchiveAPIURLQueryItemProtocol {
  var asQueryItem: URLQueryItem { get }
}


extension InternetArchive {

  public class InternetArchiveAPIController: InternetArchiveAPIControllerProtocol {
    public init(host: String = "archive.org", scheme: String = "https") {
      urlComponents.scheme = scheme
      urlComponents.host = host
    }

    public func generateSearchUrl(query: InternetArchiveAPIURLStringProtocol,
                                  start: Int,
                                  rows: Int,
                                  fields: [String],
                                  sortFields: [InternetArchiveAPIURLQueryItemProtocol],
                                  additionalQueryParams: [URLQueryItem]) -> URL? {

      let fieldParams: [URLQueryItem] = fields.compactMap { URLQueryItem(name: "fl[]", value: $0) }
      let sortParams: [URLQueryItem] = sortFields.compactMap { $0.asQueryItem }
      let params: [URLQueryItem] = sortParams + fieldParams + additionalQueryParams + [
        URLQueryItem(name: "q", value: query.asURLString),
        URLQueryItem(name: "output", value: "json"),
        URLQueryItem(name: "rows", value: "\(rows)"),
        URLQueryItem(name: "start", value: "\(start)"),
      ]

      urlComponents.path = "/advancedsearch.php"
      urlComponents.queryItems = params
      return urlComponents.url
    }

    public func generateMetadataUrl(identifier: String) -> URL? {
      urlComponents.path = "/metadata/\(identifier)"
      return urlComponents.url
    }

    public func generateDownloadUrl(itemIdentifier: String, fileName: String) -> URL? {
      urlComponents.path = "/download/\(itemIdentifier)/\(fileName)"
      return urlComponents.url
    }

    private var urlComponents: URLComponents = URLComponents()
  }
}

// Querying
extension InternetArchive {
  public struct Query: InternetArchiveAPIURLStringProtocol {
    public var params: [QueryParam]
    public var asURLString: String { // eg `collection:(etree) AND -title:(foo)`
      let paramStrings: [String] = params.compactMap { $0.asURLString }
      return paramStrings.joined(separator: " AND ")
    }

    // Convenience initializer to just pass in a bunch of key:values. Only handles boolean AND cases
    public init(fields: [String: String]) {
      let params: [QueryParam] = fields.compactMap { (param: (key: String, value: String)) -> QueryParam? in
        return QueryParam(key: param.key, value: param.value)
      }
      self.init(params: params)
    }

    public init(params: [QueryParam]) {
      self.params = params
    }
  }

  public struct QueryParam: InternetArchiveAPIURLStringProtocol {
    public let key: String
    public let value: String
    public let booleanOperator: BooleanOperator
    public var asURLString: String { // eg `collection:(etree)`, `-title:(foo)`, `(bar)`
      let urlKey: String = key.count > 0 ? "\(key):" : ""
      return "\(booleanOperator.rawValue)\(urlKey)(\(value))"
    }

    // key can be empty if you just want to search
    public init(key: String, value: String, booleanOperator: BooleanOperator = .and) {
      self.key = key
      self.value = value
      self.booleanOperator = booleanOperator
    }
  }

  public enum BooleanOperator: String {
    case and = ""
    case not = "-"
  }
}

// Sorting
extension InternetArchive {
  public struct SortField: InternetArchiveAPIURLQueryItemProtocol {
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
