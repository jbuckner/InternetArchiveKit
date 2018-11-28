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

  func testSearchQuery() {
    let expectation = XCTestExpectation(description: "Test Search Query")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : "etree", "mediatype": "collection"])
    InternetArchive().search(query: query,
                             start: 0,
                             rows: 10) { (response: InternetArchive.SearchResponse?, error: Error?) in
      if let error: Error = error {
        XCTFail("error, \(error.localizedDescription)")
        expectation.fulfill()
        return
      }

      if let response = response {
        XCTAssertTrue(response.response.numFound > 7000)  // the etree archive has 7400+ artists so just sanity check
      } else {
        XCTFail("no response")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 20.0)
  }

  func testSearchFields() {
    let expectation = XCTestExpectation(description: "Test Search Fields")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : "etree", "mediatype": "collection"])
    InternetArchive().search(query: query,
                             start: 0,
                             rows: 10,
                             fields: ["identifier", "title"]) { (response: InternetArchive.SearchResponse?, error: Error?) in
      if let error: Error = error {
        XCTFail("error, \(error.localizedDescription)")
        expectation.fulfill()
        return
      }

      if let response = response {
        if let firstDoc: InternetArchive.ItemMetadata = response.response.docs.first {
          XCTAssertNotNil(firstDoc.title)
          XCTAssertNil(firstDoc.addeddate)
        } else {
          XCTFail("no item found")
        }
      } else {
        XCTFail("no response")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 20.0)
  }

  func testSearchDateRange() {
    let expectation = XCTestExpectation(description: "Test Search Fields")

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let startDateString: String = "2018-04-19"
    let endDateString: String = "2018-04-21"

    guard
      let startDate: Date = dateFormatter.date(from: startDateString),
      let endDate: Date = dateFormatter.date(from: endDateString) else {
        XCTFail("date generation failed")
        return
    }
    let dateInterval: DateInterval = DateInterval(start: startDate, end: endDate)
    let dateRange: InternetArchive.QueryDateRange = InternetArchive.QueryDateRange(queryField: "date",
                                                                                   dateRange: dateInterval)
    let collectionClause: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "collection", value: "etree")

    let query: InternetArchive.Query = InternetArchive.Query(clauses: [dateRange, collectionClause])

    InternetArchive().search(query: query,
                             start: 0,
                             rows: 10,
                             fields: ["identifier", "title"]) { (response: InternetArchive.SearchResponse?, error: Error?) in
                              if let error: Error = error {
                                XCTFail("error, \(error.localizedDescription)")
                                expectation.fulfill()
                                return
                              }

                              if let response = response {
                                if let firstDoc: InternetArchive.ItemMetadata = response.response.docs.first {
                                  XCTAssertNotNil(firstDoc.title)
                                  XCTAssertNil(firstDoc.addeddate)
                                } else {
                                  XCTFail("no item found")
                                }
                              } else {
                                XCTFail("no response")
                              }
                              expectation.fulfill()
    }

    wait(for: [expectation], timeout: 20.0)
  }


  func testGetCollection() {
    let expectation = XCTestExpectation(description: "Test Get Collection")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : "etree", "mediatype": "collection"])
    InternetArchive().search(
      query: query,
      start: 0,
      rows: 10,
      fields: ["identifier", "title"],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        if let error: Error = error {
          XCTFail("error, \(error.localizedDescription)")
          expectation.fulfill()
          return
        }

        if let response = response {
          XCTAssertTrue(response.response.numFound > 7000)  // the etree archive has 7400+ artists so just sanity check
        } else {
          XCTFail("no response")
        }
        expectation.fulfill()
    })

    wait(for: [expectation], timeout: 20.0)
  }

  func testItemDetail() {
    let expectation = XCTestExpectation(description: "Test Item Detail")
    InternetArchive().itemDetail(identifier: "ymsb2006-07-03.flac16") { (item: InternetArchive.Item?, error: Error?) in
      if let error: Error = error {
        XCTFail("error, \(error.localizedDescription)")
        expectation.fulfill()
        return
      }

      if let item = item {
        XCTAssertEqual(item.metadata?.identifier, "ymsb2006-07-03.flac16")
      } else {
        XCTFail("no response")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 20.0)
  }
}
