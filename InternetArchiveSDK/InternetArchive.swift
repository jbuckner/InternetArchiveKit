//
//  InternetArchive.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

enum InternetArchiveError: Error {
  case invalidUrl
}

public class InternetArchive {
  let apiController: APIController = APIController()

  // hits the advancedsearch url,
  // eg https://archive.org/advancedsearch.php?q=collection:(etree)+AND+mediatype:(collection)&output=json
  func search(query: String,
              fields: [String] = [],
              start: Int = 0,
              rows: Int = 50,
              completion: @escaping (SearchResponse?, Error?) -> ()) {

    guard let searchUrl: URL = self.apiController.generateSearchUrl(query: query, fields: fields, start: start, rows: rows) else {
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: searchUrl, completion: completion)
  }

  // hits the metadata url for a particular item,
  // eg https://archive.org/metadata/ymsb2006-07-03.flac16
  func itemDetail(identifier: String, completion: @escaping (Item?, Error?) -> () ) {
    guard let metadataUrl: URL = self.apiController.generateMetadataUrl(identifier: identifier) else {
      completion(nil, InternetArchiveError.invalidUrl)
      return
    }

    self.makeRequest(url: metadataUrl, completion: completion)
  }

  // a convenience method to get a collection
  func getCollection(identifier: String,
                     completion: @escaping (SearchResponse?, Error?) -> ()) {
    let query: String = "collection:(\(identifier))+AND+mediatype:(collection)"
    self.search(query: query, completion: completion)
  }

  private func makeRequest<T>(url: URL, completion: @escaping (T?, Error?) -> ()) where T: Decodable {
    debugPrint("APIController.makeRequest", url.absoluteString)
    let task = URLSession.shared.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
      guard let data = data else {
        completion(nil, error)
        return
      }

      do {
        let results: T = try JSONDecoder().decode(T.self, from: data)
        completion(results, error)
      } catch {
        completion(nil, error)
      }
    }

    task.resume()
  }
}
