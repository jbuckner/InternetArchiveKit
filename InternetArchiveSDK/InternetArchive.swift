//
//  InternetArchive.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/6/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

public class InternetArchive {
  static func getCollection(collecton: String, completion: @escaping (SearchResponse?, Error?) -> ()) {
    let url = URL(string: "https://archive.org/advancedsearch.php?q=collection%3A%28\(collecton)%29&output=json")!

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
}
