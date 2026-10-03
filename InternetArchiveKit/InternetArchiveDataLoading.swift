//
//  InternetArchiveDataLoading.swift
//  InternetArchiveKit
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

/// The transport `InternetArchive` fetches through.
///
/// `URLSession` conforms, so the default behavior is unchanged. Provide your
/// own conformance to stub HTTP in tests or to add behavior around requests.
public protocol InternetArchiveDataLoading: Sendable {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: InternetArchiveDataLoading {
  public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    try await data(for: request, delegate: nil)
  }
}
