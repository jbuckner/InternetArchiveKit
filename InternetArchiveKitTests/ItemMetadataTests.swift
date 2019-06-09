//
//  ItemMetadataTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/9/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest

class ItemMetadataTests: XCTestCase {

  func testCanInitializeItemIdentifierOnly() {
    let metadata: InternetArchive.ItemMetadata = InternetArchive.ItemMetadata(identifier: "foo")
    XCTAssertNotNil(metadata)

    XCTAssertEqual(metadata.identifier, "foo")
  }

  func testCanInitializeItemWithParams() {
    let title = InternetArchive.ModelField<InternetArchive.IAString>(values: ["boop"])
    let year = InternetArchive.ModelField<InternetArchive.IAInt>(values: [2019])
    let metadata: InternetArchive.ItemMetadata = InternetArchive.ItemMetadata(
      identifier: "foo", title: title, year: year)
    XCTAssertNotNil(metadata)

    XCTAssertEqual(metadata.title?.value, "boop")
    XCTAssertEqual(metadata.year?.value, 2019)
    XCTAssertEqual(metadata.identifier, "foo")
  }

}
