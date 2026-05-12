//
//  FileTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 6/9/19.
//  Copyright © 2019 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON
import InternetArchiveKit

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

  func testDecodesPrivateFieldFromString() throws {
    // The Internet Archive metadata API returns `"private"` as a JSON string ("true"),
    // not a JSON boolean. `ModelField<IABool>` falls back to `IABool(fromString:)`,
    // which uses `Bool.init(_ description: String)` to parse "true" / "false".
    let json = #"""
    {
      "name": "frtr100312d1_01_Ripple.flac",
      "format": "Flac",
      "source": "original",
      "private": "true"
    }
    """#.data(using: .utf8)!

    let file = try ZippyJSONDecoder().decode(InternetArchive.File.self, from: json)
    XCTAssertEqual(file.name, "frtr100312d1_01_Ripple.flac")
    XCTAssertEqual(file.private?.value, true)
  }

  func testPrivateFieldNilWhenAbsent() throws {
    let json = #"""
    {
      "name": "frtr100312d1_01_Ripple.mp3",
      "format": "VBR MP3"
    }
    """#.data(using: .utf8)!

    let file = try ZippyJSONDecoder().decode(InternetArchive.File.self, from: json)
    XCTAssertNil(file.private)
  }

}
