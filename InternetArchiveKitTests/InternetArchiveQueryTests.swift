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

  func testEmptyQueryClauseReturnsNil() {
    let query: InternetArchive.Query = InternetArchive.Query(clauses: [])
    XCTAssertEqual(query.asURLString, nil)
  }

  func testQueryClauseMultipleValues() {
    let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", values: ["bar", "baz", "boop"])
    XCTAssertEqual(clause.asURLString, "foo:((bar) OR (baz) OR (boop))")
  }

  func testQueryClauseMultipleValuesNegative() {
    let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(
      field: "foo", values: ["bar", "baz"], booleanOperator: .not)
    XCTAssertEqual(clause.asURLString, "-foo:((bar) OR (baz))")
  }

  func testQueryClauseExactMatch() {
    let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(
      field: "foo", value: "bar", exactMatch: true)
    XCTAssertEqual(clause.asURLString, "foo:\"bar\"")
  }

  func testQueryClauseMultiValueExactMatch() {
    let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(
      field: "foo", values: ["bar", "baz"], exactMatch: true)
    XCTAssertEqual(clause.asURLString, "foo:(\"bar\" OR \"baz\")")
  }

  func testQueryClauseExactMatchDoesNotModifyRegexChars() {
    let replacementStrings = [":", "[", "]", "(", ")", "OR", "or", "AND", "and"]

    replacementStrings.forEach {
      let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(
        field: "foo", values: ["\($0)boop\($0)"], exactMatch: true)
      XCTAssertEqual(clause.asURLString, "foo:\"\($0)boop\($0)\"")
    }
  }

  func testQueryClauseFuzzyMatchRegexFix() {
    let replacementStrings = [":", "[", "]", "(", ")", "OR", "or", "AND", "and"]

    replacementStrings.forEach {
      let clause: InternetArchive.QueryClause = InternetArchive.QueryClause(
        field: "foo", values: ["\($0)boop\($0)"], exactMatch: false)
      XCTAssertEqual(clause.asURLString, "foo:(\"\($0)\"boop\"\($0)\")")
    }
  }

  func testMultipleQueryClauseFuzzyMatchRegexFix() {
    let param1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "(bar)", booleanOperator: .and, exactMatch: false)
    let param2: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "baz", value: "[boop]", booleanOperator: .not, exactMatch: true)
    let query: InternetArchive.Query = InternetArchive.Query(clauses: [param1, param2])

    XCTAssertEqual(query.asURLString, "(foo:(\"(\"bar\")\") AND -baz:\"[boop]\")")
  }

  func testSubQueryString() {
    let param1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar")
    let param2: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "baz", value: "boop", booleanOperator: .not)
    let query: InternetArchive.Query = InternetArchive.Query(clauses: [param1, param2])
    let param3: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "snip", value: "snap")
    let subQuery: InternetArchive.Query = InternetArchive.Query(clauses: [query, param3], booleanOperator: .or)
    XCTAssertEqual(subQuery.asURLString, "((foo:(bar) AND -baz:(boop)) OR snip:(snap))")
  }

  func testMoreSubQueryStrings() {
    let param1: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "foo", value: "bar")
    let param2: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "baz", value: "boop", booleanOperator: .not)
    let query: InternetArchive.Query = InternetArchive.Query(clauses: [param1, param2])
    let param3: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "snip", value: "snap")
    let param4: InternetArchive.QueryClause = InternetArchive.QueryClause(field: "blop", value: "blap")
    let query2: InternetArchive.Query = InternetArchive.Query(clauses: [param3, param4])
    let subQuery: InternetArchive.Query = InternetArchive.Query(clauses: [query, query2], booleanOperator: .or)
    XCTAssertEqual(subQuery.asURLString, "((foo:(bar) AND -baz:(boop)) OR (snip:(snap) AND blop:(blap)))")
  }

  func testQueryStringConvenience() {
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar", "baz": "boop"])
    let queryAsUrl: String? = query.asURLString
    XCTAssertTrue(queryAsUrl == "(foo:(bar) AND baz:(boop))" || queryAsUrl == "(baz:(boop) AND foo:(bar))")
    let query2: InternetArchive.Query = InternetArchive.Query(clauses: ["": "bar", "baz": "boop"])
    let query2AsUrl: String? = query2.asURLString
    XCTAssertTrue(query2AsUrl == "((bar) AND baz:(boop))" || query2AsUrl == "(baz:(boop) AND (bar))")
    let query3: InternetArchive.Query = InternetArchive.Query(clauses: ["-foo": "bar", "baz": "boop"])
    let query3AsUrl: String? = query3.asURLString
    XCTAssertTrue(query3AsUrl == "(-foo:(bar) AND baz:(boop))" || query3AsUrl == "(baz:(boop) AND -foo:(bar))")
  }

  func testQueryBooleanOr() {
    let query: InternetArchive.Query = InternetArchive.Query(
      clauses: ["foo": "bar", "baz": "boop"], booleanOperator: .or)
    let queryAsUrl: String? = query.asURLString
    XCTAssertTrue(queryAsUrl == "(foo:(bar) OR baz:(boop))" || queryAsUrl == "(baz:(boop) OR foo:(bar))")
    let query2: InternetArchive.Query = InternetArchive.Query(
      clauses: ["": "bar", "baz": "boop"], booleanOperator: .or)
    let query2AsUrl: String? = query2.asURLString
    XCTAssertTrue(query2AsUrl == "((bar) OR baz:(boop))" || query2AsUrl == "(baz:(boop) OR (bar))")
    let query3: InternetArchive.Query = InternetArchive.Query(
      clauses: ["-foo": "bar", "baz": "boop"], booleanOperator: .or)
    let query3AsUrl: String? = query3.asURLString
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
    let range: InternetArchive.QueryDateRange = InternetArchive.QueryDateRange(queryField: "date",
                                                                                   dateRange: dateInterval)

    XCTAssertEqual(range.asURLString, "date:[2018-04-19T00:00:00Z TO 2018-04-21T00:00:00Z]")
  }

  func testNumberIntRangeQuery() {
    let range: InternetArchive.QueryNumberRange = InternetArchive.QueryNumberRange(
      queryField: "downloads",
      rangeStart: 500, rangeEnd: 1000)

    XCTAssertEqual(range.asURLString, "downloads:[500 TO 1000]")
  }

  func testNumberDoubleRangeQuery() {
    let range: InternetArchive.QueryNumberRange = InternetArchive.QueryNumberRange(
      queryField: "downloads",
      rangeStart: 25.4, rangeEnd: 76.3)

    XCTAssertEqual(range.asURLString, "downloads:[25.4 TO 76.3]")
  }

  func testStringRangeQuery() {
    let range: InternetArchive.QueryStringRange = InternetArchive.QueryStringRange(
      queryField: "licenseurl",
      rangeStart: "http://creativecommons.org/a", rangeEnd: "http://creativecommons.org/z")

    XCTAssertEqual(
      range.asURLString, "licenseurl:[http://creativecommons.org/a TO http://creativecommons.org/z]")
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
