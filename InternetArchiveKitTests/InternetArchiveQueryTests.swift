//
//  InternetArchiveQueryTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 11/27/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

class InternetArchiveQueryTests: XCTestCase {

  func testQueryParamString() {
    let param1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar", booleanOperator: .and)
    XCTAssertEqual(param1.asURLString, "foo:(bar)")
    let param2: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar", booleanOperator: .not)
    XCTAssertEqual(param2.asURLString, "-foo:(bar)")
    let param3: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "", value: "bar", booleanOperator: .and)
    XCTAssertEqual(param3.asURLString, "(bar)")
  }

  func testQueryString() {
    let param1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar", booleanOperator: .and)
    let param2: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "baz", value: "boop", booleanOperator: .not)
    let param3: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "", value: "boop")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: [param1, param2, param3])

    XCTAssertEqual(query.asURLString, "(foo:(bar) AND -baz:(boop) AND (boop))")
  }

  func testQueryClauseMultipleValues() {
    let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", values: ["bar", "baz", "boop"])
    XCTAssertEqual(clause.asURLString, "foo:(bar OR baz OR boop)")
  }

  func testQueryClauseMultipleValuesNegative() {
    let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(
      field: "foo", values: ["bar", "baz"], booleanOperator: .not)
    XCTAssertEqual(clause.asURLString, "-foo:(bar OR baz)")
  }

  func testSubQueryString() {
    let param1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar")
    let param2: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "baz", value: "boop", booleanOperator: .not)
    let query: InternetArchive.Query = InternetArchive.Query(clauses: [param1, param2])
    let param3: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "snip", value: "snap")
    let subQuery: InternetArchive.Query = InternetArchive.Query(clauses: [query, param3], booleanOperator: .or)
    XCTAssertEqual(subQuery.asURLString, "((foo:(bar) AND -baz:(boop)) OR snip:(snap))")
  }

  func testQueryStringConvenience() {
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar", "baz": "boop"])
    let queryAsUrl: String = query.asURLString
    XCTAssertTrue(queryAsUrl == "(foo:(bar) AND baz:(boop))" || queryAsUrl == "(baz:(boop) AND foo:(bar))")
    let query2: InternetArchive.Query = InternetArchive.Query(clauses: ["": "bar", "baz": "boop"])
    let query2AsUrl: String = query2.asURLString
    XCTAssertTrue(query2AsUrl == "((bar) AND baz:(boop))" || query2AsUrl == "(baz:(boop) AND (bar))")
    let query3: InternetArchive.Query = InternetArchive.Query(clauses: ["-foo": "bar", "baz": "boop"])
    let query3AsUrl: String = query3.asURLString
    XCTAssertTrue(query3AsUrl == "(-foo:(bar) AND baz:(boop))" || query3AsUrl == "(baz:(boop) AND -foo:(bar))")
  }

  func testQueryBooleanOr() {
    let query: InternetArchive.Query = InternetArchive.Query(
      clauses: ["foo": "bar", "baz": "boop"], booleanOperator: .or)
    let queryAsUrl: String = query.asURLString
    debugPrint(queryAsUrl)
    XCTAssertTrue(queryAsUrl == "(foo:(bar) OR baz:(boop))" || queryAsUrl == "(baz:(boop) OR foo:(bar))")
    let query2: InternetArchive.Query = InternetArchive.Query(
      clauses: ["": "bar", "baz": "boop"], booleanOperator: .or)
    let query2AsUrl: String = query2.asURLString
    XCTAssertTrue(query2AsUrl == "((bar) OR baz:(boop))" || query2AsUrl == "(baz:(boop) OR (bar))")
    let query3: InternetArchive.Query = InternetArchive.Query(
      clauses: ["-foo": "bar", "baz": "boop"], booleanOperator: .or)
    let query3AsUrl: String = query3.asURLString
    XCTAssertTrue(query3AsUrl == "(-foo:(bar) OR baz:(boop))" || query3AsUrl == "(baz:(boop) OR -foo:(bar))")
  }

  func testSubQuery() {
    let query1: InternetArchive.Query = InternetArchive.Query(
      clauses: ["foo": "bar", "baz": "boop"], booleanOperator: .or)
    let queryClause: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "snip", value: "snap")
    let mergedQuery = InternetArchive.Query(clauses: [query1, queryClause])
    let queryAsUrl = mergedQuery.asURLString
    XCTAssertTrue(
      queryAsUrl == "((foo:(bar) OR baz:(boop)) AND snip:(snap))" ||
      queryAsUrl == "((baz:(boop) OR foo:(bar)) AND snip:(snap))" ||
      queryAsUrl == "snip:(snap)) AND ((foo:(bar) OR baz:(boop))" ||
      queryAsUrl == "snip:(snap)) AND ((baz:(boop) OR foo:(bar))"
    )
  }

  func testDateRangeQuery() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

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

    XCTAssertEqual(dateRange.asURLString, "date:[2018-04-19T00:00:00Z TO 2018-04-21T00:00:00Z]")
  }

  func testSortFieldAscending() {
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "foo", direction: .asc)
    XCTAssertEqual(sortField.asQueryItem.name, "sort[]")
    XCTAssertEqual(sortField.asQueryItem.value, "foo asc")
  }

  func testSortFieldDescending() {
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "foo", direction: .desc)
    XCTAssertEqual(sortField.asQueryItem.name, "sort[]")
    XCTAssertEqual(sortField.asQueryItem.value, "foo desc")
  }
}
