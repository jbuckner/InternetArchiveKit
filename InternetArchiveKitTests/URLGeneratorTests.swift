//
//  APIControllerTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 11/10/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import XCTest
@testable import InternetArchiveKit

class APIControllerTests: XCTestCase {

  func testGenerateSearchUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar", "baz": "boop"])
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "foo", direction: .asc)
    if let url: URL = urlGenerator.generateSearchUrl(query: query,
                                                     page: 0,
                                                     rows: 10,
                                                     fields: ["foo", "bar"],
                                                     sortFields: [sortField],
                                                     additionalQueryParams: []) {
      let absoluteUrl: String = url.absoluteString
      debugPrint(absoluteUrl)
      // these are not necessarily always in the same order so just search
      XCTAssertTrue(absoluteUrl.contains("sort%5B%5D=foo%20asc"))
      XCTAssertTrue(absoluteUrl.contains("fl%5B%5D=foo"))
      XCTAssertTrue(absoluteUrl.contains("fl%5B%5D=bar"))
      XCTAssertTrue(absoluteUrl.contains("q=(foo:(bar)%20AND%20baz:(boop))") || absoluteUrl.contains("q=(baz:(boop)%20AND%20foo:(bar))"))
      XCTAssertTrue(absoluteUrl.contains("output=json"))
      XCTAssertTrue(absoluteUrl.contains("rows=10"))
      XCTAssertTrue(absoluteUrl.contains("page=0"))
    } else {
      XCTFail("Error generating search URL")
    }
  }

  func testGenerateScrapeUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar"])
    let sortField: InternetArchive.SortField = InternetArchive.SortField(field: "date", direction: .desc)
    guard
      let url: URL = urlGenerator.generateScrapeUrl(query: query,
                                                    fields: ["identifier", "title"],
                                                    sortFields: [sortField],
                                                    pagination: .cursor("abc123"),
                                                    additionalQueryParams: []),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        XCTFail("Error generating scrape URL")
        return
    }

    XCTAssertEqual(components.scheme, "gopher")
    XCTAssertEqual(components.host, "foohost.org")
    XCTAssertEqual(components.path, "/services/search/v1/scrape")

    // parse the query items back so the assertions don't depend on percent-encoding
    let items: [String: String] = (components.queryItems ?? []).reduce(into: [:]) { $0[$1.name] = $1.value }
    XCTAssertEqual(items["q"], "(foo:(bar))")
    XCTAssertEqual(items["fields"], "identifier,title")  // comma-delimited, not repeated fl[]
    XCTAssertEqual(items["sorts"], "date desc")  // comma-delimited, not repeated sort[]
    XCTAssertEqual(items["cursor"], "abc123")
    XCTAssertNil(items["count"])  // `.cursor` and `.count` are mutually exclusive
  }

  func testGenerateScrapeUrlWithCount() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar"])
    guard
      let url: URL = urlGenerator.generateScrapeUrl(query: query,
                                                    fields: [],
                                                    sortFields: [],
                                                    pagination: .count(500),
                                                    additionalQueryParams: []),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        XCTFail("Error generating scrape URL")
        return
    }

    let items: [String: String] = (components.queryItems ?? []).reduce(into: [:]) { $0[$1.name] = $1.value }
    XCTAssertEqual(items["count"], "500")
    XCTAssertNil(items["cursor"])  // `.count` and `.cursor` are mutually exclusive
  }

  func testGenerateScrapeUrlOmitsEmptyParams() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    let query: InternetArchive.Query = InternetArchive.Query(clauses: ["foo": "bar"])
    guard
      let url: URL = urlGenerator.generateScrapeUrl(query: query,
                                                    fields: [],
                                                    sortFields: [],
                                                    pagination: nil,
                                                    additionalQueryParams: []),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        XCTFail("Error generating scrape URL")
        return
    }

    let names: Set<String> = Set((components.queryItems ?? []).map { $0.name })
    XCTAssertTrue(names.contains("q"))
    XCTAssertFalse(names.contains("fields"))
    XCTAssertFalse(names.contains("sorts"))
    XCTAssertFalse(names.contains("cursor"))
    XCTAssertFalse(names.contains("count"))
  }

  func testScrapeSortMisplacesIdentifier() {
    let id = InternetArchive.SortField(field: "identifier", direction: .asc)
    let date = InternetArchive.SortField(field: "date", direction: .desc)
    let downloads = InternetArchive.SortField(field: "downloads", direction: .desc)

    // valid: identifier absent, alone, or last
    XCTAssertFalse(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([]))
    XCTAssertFalse(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([date]))
    XCTAssertFalse(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([id]))
    XCTAssertFalse(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([date, id]))
    XCTAssertFalse(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([downloads, id]))

    // invalid: identifier present but not last
    XCTAssertTrue(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([id, date]))
    XCTAssertTrue(InternetArchive.URLGenerator.scrapeSortMisplacesIdentifier([id, downloads, date]))
  }

  func testGenerateDownloadUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    if let url: URL = urlGenerator.generateDownloadUrl(itemIdentifier: "foo", fileName: "bar") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/download/foo/bar")
    } else {
      XCTFail("Error generating download URL")
    }
  }

  func testGenerateImageUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    if let url: URL = urlGenerator.generateItemImageUrl(itemIdentifier: "foo") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/services/img/foo")
    } else {
      XCTFail("Error generating download URL")
    }
  }

  func testGenerateMetadataUrl() {
    let urlGenerator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "gopher")
    if let url: URL = urlGenerator.generateMetadataUrl(identifier: "foo") {
      XCTAssertEqual(url.absoluteString, "gopher://foohost.org/metadata/foo")
    } else {
      XCTFail("Error generating download URL")
    }
  }

}

class PlusEncodingTests: XCTestCase {
  private let generator = InternetArchive.URLGenerator(host: "foohost.org", scheme: "https")

  func testPlusInSearchQueryIsEncoded() {
    let query = InternetArchive.Query(clauses: ["title": "a+b"])
    let url = generator.generateSearchUrl(
      query: query, page: 1, rows: 10, fields: ["identifier"], sortFields: [], additionalQueryParams: [])
    XCTAssertEqual(
      url?.absoluteString,
      "https://foohost.org/advancedsearch.php?fl%5B%5D=identifier&q=(title:(a%2Bb))&output=json&rows=10&page=1")
  }

  func testPlusInScrapeQueryIsEncoded() {
    let query = InternetArchive.Query(clauses: ["title": "a+b"])
    let url = generator.generateScrapeUrl(
      query: query, fields: ["identifier"], sortFields: [], pagination: nil, additionalQueryParams: [])
    XCTAssertEqual(
      url?.absoluteString,
      "https://foohost.org/services/search/v1/scrape?q=(title:(a%2Bb))&fields=identifier")
  }

  func testRepresentativeLMAUrlsAreUnchanged() {
    let query = InternetArchive.Query(clauses: [
      "collection": "etree", "date": "1977-05-08",
    ])
    let sort = InternetArchive.SortField(field: "date", direction: .desc)
    let search = generator.generateSearchUrl(
      query: InternetArchive.QueryClause(field: "collection", value: "etree"),
      page: 2, rows: 50, fields: ["identifier", "title"], sortFields: [sort], additionalQueryParams: [])
    XCTAssertEqual(
      search?.absoluteString,
      "https://foohost.org/advancedsearch.php?sort%5B%5D=date%20desc&fl%5B%5D=identifier&fl%5B%5D=title&q=collection:(etree)&output=json&rows=50&page=2")
    let scrape = generator.generateScrapeUrl(
      query: query, fields: ["identifier", "title"], sortFields: [sort], pagination: .count(100),
      additionalQueryParams: [])
    XCTAssertFalse(scrape?.absoluteString.contains("%2B") ?? true)
    XCTAssertFalse(scrape?.absoluteString.contains("+") ?? true)
    let ids = InternetArchive.QueryClause(field: "identifier", values: ["gd77-05-08", "gd77-05-09"])
    let idsURL = generator.generateScrapeUrl(
      query: ids, fields: [], sortFields: [], pagination: .cursor("abc123"), additionalQueryParams: [])
    XCTAssertEqual(
      idsURL?.absoluteString,
      "https://foohost.org/services/search/v1/scrape?q=identifier:((gd77-05-08)%20OR%20(gd77-05-09))&cursor=abc123"
    )
  }
}
