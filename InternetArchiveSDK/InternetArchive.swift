//
//  InternetArchive.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public class InternetArchive {
  static let baseUrl: String = "https://archive.org"

  // hits the advancedsearch url,
  // ie https://archive.org/advancedsearch.php?q=collection:(etree)+AND+mediatype:(collection)&output=json
  static func search(query: String, fields: String?, completion: @escaping (SearchResponse?, Error?) -> ()) {
    let url = URL(string: "\(baseUrl)/advancedsearch.php?q=\(query)&output=json")!

    debugPrint("InternetArchive.getCollection", url)

    let task = URLSession.shared.dataTask(with: url) {(data: Data?, response: URLResponse?, error: Error?) in
      guard let data = data else {
        completion(nil, error)
        return
      }

      do {
        let results: SearchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        completion(results, error)
      } catch {
        completion(nil, error)
      }
    }

    task.resume()
  }

  // hits the metadata url for a particular item,
  // ie https://archive.org/metadata/ymsb2006-07-03.flac16
  static func itemDetail(identifier: String, completion: @escaping (Item?, Error?) -> () ) {

  }

  static func getCollection(collecton: String,
                            mediatype: String? = nil,
                            completion: @escaping (SearchResponse?, Error?) -> ()) {
    let query: String = "collection:(\(collecton))+AND+mediatype:(collection)"
    self.search(query: query, fields: nil, completion: completion)
  }
}
