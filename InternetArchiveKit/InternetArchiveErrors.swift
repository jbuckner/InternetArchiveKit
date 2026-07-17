//
//  InternetArchiveErrors.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   Errors that may be returned by the InternetArchive class
   */
  public enum InternetArchiveError: Error, Equatable {
    case invalidUrl

    /// The API answered HTTP 200 but the body was an error envelope
    /// (`{"error": "…"}`) instead of the expected payload. archive.org
    /// signals rejected searches this way — for example a `q` parameter
    /// over ~2,000 characters returns
    /// `{"error": "[UNSUPPORTED_VALUE] …"}` with no `response` block.
    /// `message` carries the API's error string.
    case apiError(message: String)

    /// A `scrape()` request was given sort fields archive.org would reject,
    /// caught client-side before the request is sent. archive.org requires
    /// `identifier`, if it appears in a scrape sort, to be the last sort field.
    /// `message` explains what to fix.
    case invalidSortFields(message: String)

    /// The server answered with a non-2xx HTTP status and the body carried
    /// no `{"error": …}` envelope to explain it.
    case httpError(statusCode: Int)
  }
}

extension InternetArchive.InternetArchiveError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidUrl:
      return "Invalid URL"
    case .apiError(let message):
      return "Internet Archive API error: \(message)"
    case .invalidSortFields(let message):
      return "Invalid sort fields: \(message)"
    case .httpError(let statusCode):
      return "HTTP error \(statusCode)"
    }
  }
}

extension InternetArchive {
  /// The HTTP-200 error envelope shape, e.g.
  /// `{"error": "[UNSUPPORTED_VALUE] …"}`. Used to distinguish an API
  /// rejection from a payload-shape decoding failure in `makeRequest`.
  struct APIErrorEnvelope: Decodable {
    let error: String
  }
}
