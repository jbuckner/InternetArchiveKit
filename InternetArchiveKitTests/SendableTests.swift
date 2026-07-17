//
//  SendableTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

/// Compile-time proof that the response models can cross concurrency domains.
/// If a conformance regresses, `requireSendable` stops compiling.
class SendableTests: XCTestCase {
  private func requireSendable<T: Sendable>(_ type: T.Type) {}

  func testResponseModelsAreSendable() {
    requireSendable(InternetArchive.SearchResponse.self)
    requireSendable(InternetArchive.ResponseHeader.self)
    requireSendable(InternetArchive.Response.self)
    requireSendable(InternetArchive.ResponseParams.self)
    requireSendable(InternetArchive.ScrapeResponse.self)
    requireSendable(InternetArchive.Item.self)
    requireSendable(InternetArchive.ItemMetadata.self)
    requireSendable(InternetArchive.File.self)
    requireSendable(InternetArchive.Review.self)
    requireSendable(InternetArchive.ModelField<InternetArchive.IAInt>.self)
    requireSendable(InternetArchive.ModelField<InternetArchive.IAString>.self)
    requireSendable(InternetArchive.ModelField<InternetArchive.IADate>.self)
  }
}
