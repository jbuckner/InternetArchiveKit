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
    let query: String
    let qin: String
    let fields: String
    let wt: String
    let rows: String?
    let start: Int
  }

  public struct ResponseHeader: Decodable {
    let status: Int
    let QTime: Int
    let params: ResponseParams
  }

  public struct Response: Decodable {
    let numFound: Int
    let start: Int
    let docs: [ItemMetadata]
  }

  public struct SearchResponse: Decodable {
    let responseHeader: ResponseHeader
    let response: Response
  }

}
