//
//  ItemTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/9/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest

class ItemTests: XCTestCase {

  func testCanInitializeItemNoParams() {
    let item: InternetArchive.Item = InternetArchive.Item()
    XCTAssertNotNil(item)
    
    XCTAssertNil(item.creator)
  }

  func testCanInitializeItemWithParams() {
    let creator = InternetArchive.ModelField<InternetArchive.IAString>(values: ["foo"])
    let isCollection = InternetArchive.ModelField<InternetArchive.IABool>(values: [false])
    let item: InternetArchive.Item = InternetArchive.Item(creator: creator, isCollection: isCollection)
    XCTAssertNotNil(item)

    XCTAssertEqual(item.creator?.value, "foo")
    XCTAssertEqual(item.isCollection?.value, false)
  }

}
