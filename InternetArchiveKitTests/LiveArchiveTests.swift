//
//  LiveArchiveTests.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest

@testable import InternetArchiveKit

/// Checks against the real archive.org. They're skipped unless `IAKIT_LIVE_TESTS=1`, and run
/// in the scheduled "Live archive.org" workflow instead of on pull requests.
///
/// These assert that the query is honored, not just that some count is large. A count
/// threshold passes against a backend that ignores the query entirely, which is what the
/// Scrape API did on 2026-10-03: every `q` returned the same 9,294 results.
final class LiveArchiveTests: XCTestCase {
  override func setUpWithError() throws {
    try TestArchive.requireLive()
  }

  func testSearchHonorsTheQuery() async throws {
    let archive = TestArchive.make()
    let known = try await archive.search(
      query: InternetArchive.QueryClause(field: "identifier", value: "goody"),
      page: 1, rows: 10
    ).get()
    XCTAssertEqual(known.response.docs.map(\.identifier), ["goody"])

    let nonsense = try await archive.search(
      query: InternetArchive.QueryClause(
        field: "identifier", value: "zzzznotarealidentifierzzzz"),
      page: 1, rows: 10
    ).get()
    XCTAssertEqual(nonsense.response.numFound, 0)
  }

  func testScrapeHonorsTheQuery() async throws {
    let archive = TestArchive.make()
    let known: InternetArchive.ScrapeResponse = try await archive.scrape(
      query: InternetArchive.QueryClause(field: "identifier", value: "goody"),
      fields: ["identifier"], sortFields: nil, pagination: nil)
    XCTAssertEqual(known.items.map(\.identifier), ["goody"])

    let nonsense: InternetArchive.ScrapeResponse = try await archive.scrape(
      query: InternetArchive.QueryClause(
        field: "identifier", value: "zzzznotarealidentifierzzzz"),
      fields: ["identifier"], sortFields: nil, pagination: nil)
    XCTAssertEqual(nonsense.total, 0)
  }

  /// `total_only` must agree with advancedsearch's count. Some of the time the Scrape API
  /// reports about double the real count for this query (18,306 against 9,341 on 2026-11-19),
  /// so the check is that it never undercounts and is within twice the real count.
  /// `ImplausibleScrapeRetrier` already retries a total of 1.
  func testScrapeTotalMatchesSearch() async throws {
    let archive = TestArchive.make()
    let query = InternetArchive.Query(clauses: ["collection": "etree", "mediatype": "collection"])
    let total: Int = try await archive.scrapeTotal(query: query)
    let searched = try await archive.search(query: query, page: 1, rows: 10).get()
    let real = searched.response.numFound
    XCTAssertGreaterThanOrEqual(total, real - 50, "scrape total undercounts")
    XCTAssertLessThanOrEqual(total, real * 2 + 50, "scrape total is over twice the search count")
  }
}
