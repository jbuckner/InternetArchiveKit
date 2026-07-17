//
//  ViewsTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 7/17/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import URLSessionMock
@testable import InternetArchiveKit

class ViewsTests: XCTestCase {

  func testGenerateViewsUrl() {
    let generator = InternetArchive.URLGenerator()
    XCTAssertEqual(
      generator.generateViewsUrl(identifiers: ["foo", "bar_baz"])?.absoluteString,
      "https://be-api.us.archive.org/views/v1/short/foo,bar_baz"
    )
    XCTAssertNil(generator.generateViewsUrl(identifiers: []))
  }

  // identifiers can contain underscores, so views responses decode without
  // the snake-case key strategy that would mangle them
  func testViewsDecodingPreservesIdentifierKeys() async {
    let json: String = """
      {"foo_bar": {"have_data": true, "all_time": 10, "last_30day": 2, "last_7day": 1}}
    """
    guard let data: Data = json.data(using: .utf8) else {
      XCTFail("error encoding json to data")
      return
    }

    let urlGenerator = InternetArchive.URLGenerator()
    guard let url = urlGenerator.generateViewsUrl(identifiers: ["foo_bar"]) else {
      XCTFail("error generating views url")
      return
    }

    let endpoint = BasicEndpointMock(
      status: 200, url: url, body: data, headers: nil, error: nil)
    URLSession.mockEndpoints = [url: endpoint]

    let archive = InternetArchive(
      urlGenerator: urlGenerator, urlSession: URLSession.mock)
    let result = await archive.views(identifiers: ["foo_bar"])
    switch result {
    case .success(let views):
      XCTAssertEqual(views["foo_bar"]?.haveData, true)
      XCTAssertEqual(views["foo_bar"]?.allTime, 10)
      XCTAssertEqual(views["foo_bar"]?.last30Day, 2)
      XCTAssertEqual(views["foo_bar"]?.last7Day, 1)
    case .failure(let error):
      XCTFail("error, \(error.localizedDescription)")
    }
  }

  func testViewsLive() async throws {
    let views: [String: InternetArchive.ItemViews] = try await InternetArchive().views(
      identifiers: ["gd73-06-10.sbd.hollister.174.sbeok.shnf"])
    guard let itemViews = views["gd73-06-10.sbd.hollister.174.sbeok.shnf"] else {
      XCTFail("no views entry for the requested identifier")
      return
    }
    XCTAssertTrue(itemViews.haveData)
    XCTAssertTrue(itemViews.allTime > 0)
  }
}
