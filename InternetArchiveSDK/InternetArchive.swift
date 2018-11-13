//
//  InternetArchive.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public class InternetArchive {
  public init(apiController: InternetArchiveAPIControllerProtocol = InternetArchiveAPIController()) {
    self.apiController = apiController
  }

  // hits the advancedsearch url,
  // eg https://archive.org/advancedsearch.php?q=collection:(etree)+AND+mediatype:(collection)&outpt=json
  public func search(query: Query,
                     start: Int,
                     rows: Int,
                     fields: [String] = [],
                     sortFields: [SortField] = [],
                     completion: @escaping (SearchResponse?, Error?) -> ()) {

    guard let searchUrl: URL = self.apiController.generateSearchUrl(query: query,
                                                                    start: start,
                                                                    rows: rows,
                                                                    fields: fields,
                                                                    sortFields: sortFields,
                                                                    additionalQueryParams: []) else {
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.apiController.makeRequest(url: searchUrl, completion: completion)
  }

  // hits the metadata url for a particular item,
  // eg https://archive.org/metadata/ymsb2006-07-03.flac16
  public func itemDetail(identifier: String, completion: @escaping (Item?, Error?) -> () ) {
    guard let metadataUrl: URL = self.apiController.generateMetadataUrl(identifier: identifier) else {
      debugPrint("itemDetail error generating metadata url, identifier", identifier)
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.apiController.makeRequest(url: metadataUrl, completion: completion)
  }

  private let apiController: InternetArchiveAPIControllerProtocol
}

extension InternetArchive {
  public enum InternetArchiveError: Error {
    case invalidUrl
  }
}
