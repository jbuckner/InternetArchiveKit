//
//  ScrapeResponseTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/23/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

class ScrapeResponseTests: XCTestCase {
  func testInit() {
    let item = InternetArchive.ItemMetadata(identifier: "foo")
    let response = InternetArchive.ScrapeResponse(
      items: [item], count: 1, total: 10, cursor: "next", previous: "prev")
    XCTAssertEqual(response.items.first?.identifier, "foo")
    XCTAssertEqual(response.count, 1)
    XCTAssertEqual(response.total, 10)
    XCTAssertEqual(response.cursor, "next")
    XCTAssertEqual(response.previous, "prev")
  }

  func testInitDefaultsCursorAndPreviousToNil() {
    let response = InternetArchive.ScrapeResponse(items: [], count: 0, total: 0)
    XCTAssertNil(response.cursor)
    XCTAssertNil(response.previous)
  }
}
