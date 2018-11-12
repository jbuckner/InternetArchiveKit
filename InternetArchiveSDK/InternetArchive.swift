//
//  InternetArchive.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public class InternetArchive {
  let apiController: InternetArchiveAPIControllerProtocol

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

    self.makeRequest(url: searchUrl, completion: completion)
  }

  // hits the metadata url for a particular item,
  // eg https://archive.org/metadata/ymsb2006-07-03.flac16
  public func itemDetail(identifier: String, completion: @escaping (Item?, Error?) -> () ) {
    guard let metadataUrl: URL = self.apiController.generateMetadataUrl(identifier: identifier) else {
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: metadataUrl, completion: completion)
  }

  private func makeRequest<T>(url: URL, completion: @escaping (T?, Error?) -> ()) where T: Decodable {
    debugPrint("APIController.makeRequest", url.absoluteString)
    let task = URLSession.shared.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
      guard let data = data else {
        completion(nil, error)
        return
      }

      do {
        let decoder: JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let results: T = try decoder.decode(T.self, from: data)
        completion(results, error)
      } catch {
        debugPrint("makeRequest error decoding", error.localizedDescription)
        completion(nil, error)
      }
    }

    task.resume()
  }
}

extension InternetArchive {
  public enum InternetArchiveError: Error {
    case invalidUrl
  }
}
