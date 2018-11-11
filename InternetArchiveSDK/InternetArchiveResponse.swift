//
//  IAResponse.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {

  public struct ResponseParams: Decodable {
    public let query: String
    public let qin: String
    public let fields: String
    public let wt: String
    public let rows: String?
    public let start: Int
  }

  public struct ResponseHeader: Decodable {
    public let status: Int
    public let QTime: Int
    public let params: ResponseParams
  }

  public struct Response: Decodable {
    public let numFound: Int
    public let start: Int
    public let docs: [ItemMetadata]
  }

  public struct SearchResponse: Decodable {
    public let responseHeader: ResponseHeader
    public let response: Response
  }

}
