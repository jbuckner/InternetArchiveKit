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
    
    public init(
      responseHeader: ResponseHeader,
      response: Response
    ) {
      self.responseHeader = responseHeader
      self.response = response
    }
  }

  /**
   The response headers from a search request
   */
  public struct ResponseHeader: Decodable {
    public let status: Int
    public let QTime: Int
    public let params: ResponseParams
    
    public init(
      status: Int,
      QTime: Int,
      params: ResponseParams
    ) {
      self.status = status
      self.QTime = QTime
      self.params = params
    }
  }

  /**
   The response from a search request, containing the search results (`docs`)
   */
  public struct Response: Decodable {
    public let numFound: Int
    public let start: Int
    public let docs: [ItemMetadata]
    
    public init(
      numFound: Int,
      start: Int,
      docs: [ItemMetadata]
    ) {
      self.numFound = numFound
      self.start = start
      self.docs = docs
    }
  }

  /**
   The response parameters from a search request

   This contains the query information that you sent in the search request.
   */
  public struct ResponseParams: Decodable {
    public let query: String
    public let qin: String
    public let fields: String
    public let wt: String // swiftlint:disable:this identifier_name
    // this is a ModelField<IAInt> because the Archive switched
    // from a string to a number and broke parsing so this
    // adds resiliency to the data type
    public let rows: ModelField<IAInt>?
    public let start: Int
    
    public init(
      query: String,
      qin: String,
      fields: String,
      wt: String,
      rows: ModelField<IAInt>?,
      start: Int
    ) {
      self.query = query
      self.qin = qin
      self.fields = fields
      self.wt = wt
      self.rows = rows
      self.start = start
    }
  }
}
