//
//  IAResponse.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

struct ResponseParams: Decodable {
  let query: String
  let qin: String
  let fields: String
  let wt: String
  let rows: String?
  let start: Int
}

struct ResponseHeader: Decodable {
  let status: Int
  let QTime: Int
  let params: ResponseParams
}

struct Response: Decodable {
  let numFound: Int
  let start: Int
  let docs: [ItemMetadata]
}

struct SearchResponse: Decodable {
  let responseHeader: ResponseHeader
  let response: Response
}
