//
//  InternetArchiveSDKTests.swift
//  InternetArchiveSDKTests
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveSDK

class InternetArchiveSDKTests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testGetCollection() {
    let expectation = XCTestExpectation(description: "Test Object Manager Nil")
    InternetArchive.getCollection(collecton: "YonderMountainStringBand") { (response: SearchResponse?, error: Error?) in
      XCTAssertNotNil(response)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10.0)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
