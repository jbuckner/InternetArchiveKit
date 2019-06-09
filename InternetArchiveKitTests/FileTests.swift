//
//  FileTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/9/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest

class FileTests: XCTestCase {

  func testCanInitializeFileOnlyName() {
    let file: InternetArchive.File = InternetArchive.File(name: "foo")
    XCTAssertNotNil(file)

    XCTAssertEqual(file.name, "foo")
  }

  func testCanInitializeFileWithParams() {
    let title = InternetArchive.ModelField<InternetArchive.IAString>(values: ["boop"])
    let track = InternetArchive.ModelField<InternetArchive.IAInt>(values: [3])
    let file: InternetArchive.File = InternetArchive.File(name: "foo", title: title, track: track)
    XCTAssertNotNil(file)

    XCTAssertEqual(file.title?.value, "boop")
    XCTAssertEqual(file.track?.value, 3)
    XCTAssertEqual(file.name, "foo")
  }

}
