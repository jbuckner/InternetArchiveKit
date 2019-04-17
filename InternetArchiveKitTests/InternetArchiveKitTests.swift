//
//  InternetArchiveKitTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

class InternetArchiveKitTests: XCTestCase {
  
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
                             page: 0,
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
                             page: 0,
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
                             page: 0,
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
      page: 0,
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

  func testTrackLength() {
    let expectation = XCTestExpectation(description: "Test Item Files")
    InternetArchive().itemDetail(identifier: "ymsb2006-07-03.flac16") { (item: InternetArchive.Item?, error: Error?) in
      if let error: Error = error {
        XCTFail("error, \(error.localizedDescription)")
        expectation.fulfill()
        return
      }

      if let item = item {
        // these two files have different length formats:
        // length: "03:12"
        if let file = item.files?.first(where: { $0.name == "ymsb2006-07-03d1t04.mp3" }) {
          XCTAssertEqual(file.length?.value, 192)
        } else {
          XCTFail("file not found")
        }

        // length: "333.98"
        if let file = item.files?.first(where: { $0.name == "ymsb2006-07-03d2t09.flac" }) {
          XCTAssertEqual(file.length?.value, 333.98)
        } else {
          XCTFail("file not found")
        }
      } else {
        XCTFail("no response")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 20.0)
  }

  // To test pagination, I first make a request to internet archive and get the number of documents in the response
  // I then make another request to get the last page of results, which should be contain less than or equal to the
  // number of rows requested and the response document count should match that number.
  // The remaining count is calculatable from the response with `numFound - start`
  // eg 2638 total results, start at 2630, page 264 (0-indexed) there should be 8 results returned when requesting 10 at a time
  func testPagination() {
    let expectation = XCTestExpectation(description: "Test Pagination")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : "etree", "mediatype": "collection"])
    let rowsPerPage: Int = 10

    InternetArchive().search(
      query: query,
      page: 0,
      rows: rowsPerPage,
      fields: ["identifier", "title"],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        if let error: Error = error {
          XCTFail("error, \(error.localizedDescription)")
          expectation.fulfill()
          return
        }

        if let response = response {
          let total = response.response.numFound
          let lastPage = Int(Double(total) / Double(10)) + 1

          InternetArchive().search(
            query: query,
            page: lastPage,
            rows: rowsPerPage,
            fields: ["identifier", "title"],
            completion: { (response: InternetArchive.SearchResponse?, error: Error?) in

              if let response = response {
                let numFound = response.response.numFound
                let start = response.response.start
                let remaining = numFound - start
                debugPrint(numFound, start, remaining)
                XCTAssertTrue(remaining <= rowsPerPage)
                XCTAssertEqual(remaining, response.response.docs.count)
              } else {
                XCTFail("no response")
              }

              expectation.fulfill()
          })
        } else {
          XCTFail("no response")
          expectation.fulfill()
        }
    })

    wait(for: [expectation], timeout: 20.0)
  }

  func testOaiUpdated() {
    let expectation = XCTestExpectation(description: "Test OaiUpdated")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["collection" : "etree", "mediatype": "collection"])
    InternetArchive().search(
      query: query,
      page: 0,
      rows: 10,
      fields: ["identifier", "title", "oai_updatedate"],
      sortFields: [InternetArchive.SortField(field: "oai_updatedate", direction: .desc)],
      completion: { (response: InternetArchive.SearchResponse?, error: Error?) in
        if let error: Error = error {
          XCTFail("error, \(error.localizedDescription)")
          expectation.fulfill()
          return
        }

        if let response = response {
          XCTAssertNotNil(response.response.docs.first?.oaiUpdatedate?.value)
        } else {
          XCTFail("no response")
        }
        expectation.fulfill()
    })

    wait(for: [expectation], timeout: 20.0)

  }

}
