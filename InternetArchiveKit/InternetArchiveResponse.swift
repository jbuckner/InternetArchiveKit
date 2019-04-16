//
//  IAResponse.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {

  /**
   The top-level response from a search request
   */
  public struct SearchResponse: Decodable {
    public let responseHeader: ResponseHeader
    public let response: Response
  }

  /**
   The response headers from a search request
   */
  public struct ResponseHeader: Decodable {
    public let status: Int
    public let QTime: Int
    public let params: ResponseParams
  }

  /**
   The response from a search request, containing the search results (`docs`)
   */
  public struct Response: Decodable {
    public let numFound: Int
    public let start: Int
    public let docs: [ItemMetadata]
  }

  /**
   The response parameters from a search request

   This contains the query information that you sent in the search request.
   */
  public struct ResponseParams: Decodable {
    public let query: String
    public let qin: String
    public let fields: String
    public let wt: String
    public let rows: String?
    public let start: Int
  }

}
