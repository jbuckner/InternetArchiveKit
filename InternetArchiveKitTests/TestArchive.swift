//
//  TestArchive.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest

@testable import InternetArchiveKit

/// Where a test's `InternetArchive` gets its answers.
///
/// By default it's a `RecordedArchive`: a small, deterministic archive built from
/// responses recorded off archive.org, served through `InternetArchiveDataLoading`. That
/// keeps the suite offline, so a change on archive.org's side can't fail a pull request.
///
/// Set `IAKIT_LIVE_TESTS=1` to run the same tests against the real archive.org. They run
/// in the scheduled "Live archive.org" workflow, which doesn't gate merges.
enum TestArchive {
  static var isLive: Bool {
    ProcessInfo.processInfo.environment["IAKIT_LIVE_TESTS"] == "1"
  }

  static func make() -> InternetArchive {
    isLive ? InternetArchive() : InternetArchive(dataLoader: RecordedArchive())
  }

  /// How many etree collections a "sanity check" test should expect. Live, the real index
  /// holds thousands. The recording holds a fixed 115 of them.
  static var minimumCollections: Int { isLive ? 7000 : 100 }

  /// Skips the calling test unless it's running against the real archive.org.
  static func requireLive() throws {
    try XCTSkipUnless(isLive, "set IAKIT_LIVE_TESTS=1 to run against archive.org")
  }
}

/// A tiny archive.org stand-in built from `MockResponse/recordedCollections.json` (115 real
/// etree collections) and `MockResponse/recordedItem*.json` (real `/metadata/<id>` bodies).
///
/// It understands the three requests the suite makes: advancedsearch paging, Scrape API
/// cursors and `total_only`, and item metadata. The query itself is ignored. Every search
/// is the etree collection list, which is all the tests ask for.
final class RecordedArchive: InternetArchiveDataLoading, @unchecked Sendable {
  /// Scrape batches larger than the 100-item minimum, as the real API's are.
  static let defaultScrapeBatch = 110

  private let docs: [[String: Any]]
  private(set) var requests: [URL] = []

  init() {
    let recorded = Self.json("recordedCollections.json") as? [String: Any]
    self.docs = (recorded?["docs"] as? [[String: Any]]) ?? []
  }

  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    let url = request.url ?? URL(fileURLWithPath: "/")
    requests.append(url)
    let (status, body) = respond(to: url)
    let response = HTTPURLResponse(
      url: url, statusCode: status, httpVersion: nil, headerFields: nil)
    return (body, response ?? URLResponse())
  }

  // MARK: - Routing

  private func respond(to url: URL) -> (Int, Data) {
    let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    func value(_ name: String) -> String? { items.first { $0.name == name }?.value }

    if url.path == "/advancedsearch.php" {
      let fields = items.filter { $0.name == "fl[]" }.compactMap(\.value)
      return (
        200,
        search(
          page: Int(value("page") ?? "") ?? 1, rows: Int(value("rows") ?? "") ?? 10, fields: fields)
      )
    }
    if url.path == "/services/search/v1/scrape" {
      if value("total_only") == "true" {
        return (200, encode(["items": [Any](), "count": 0, "total": docs.count]))
      }
      return (
        200,
        scrape(
          count: Int(value("count") ?? "") ?? Self.defaultScrapeBatch,
          cursor: value("cursor"),
          fields: (value("fields") ?? "").split(separator: ",").map(String.init))
      )
    }
    if url.path.hasPrefix("/metadata/") {
      let identifier = String(url.path.dropFirst("/metadata/".count))
      if let data = Self.fixtureData("recordedItem\(Self.fixtureSuffix(identifier)).json") {
        return (200, data)
      }
      return (200, encode(["error": "Couldn't locate item '\(identifier)'"]))
    }
    return (404, Data())
  }

  /// The real API's `page` is 1-based, and a page past the end holds the remainder.
  private func search(page: Int, rows: Int, fields: [String]) -> Data {
    let start = max(page - 1, 0) * rows
    let slice = Array(docs.dropFirst(start).prefix(rows)).map { project($0, to: fields) }
    return encode([
      "responseHeader": [
        "status": 0, "QTime": 1,
        "params": [
          "query": "recorded", "qin": "recorded", "fields": fields.joined(separator: ","),
          "wt": "json", "rows": "\(rows)", "start": start,
        ] as [String: Any],
      ] as [String: Any],
      "response": ["numFound": docs.count, "start": start, "docs": slice] as [String: Any],
    ])
  }

  /// Cursors are opaque to callers. Here one is just the offset of the next batch.
  private func scrape(count: Int, cursor: String?, fields: [String]) -> Data {
    let offset = cursor.flatMap { Int($0.replacingOccurrences(of: "recorded-", with: "")) } ?? 0
    let slice = Array(docs.dropFirst(offset).prefix(count)).map { project($0, to: fields) }
    var body: [String: Any] = ["items": slice, "count": slice.count, "total": docs.count]
    if offset + slice.count < docs.count { body["cursor"] = "recorded-\(offset + slice.count)" }
    if offset > 0 { body["previous"] = "recorded-\(max(offset - count, 0))" }
    return encode(body)
  }

  /// A real response only carries the fields that were asked for.
  private func project(_ doc: [String: Any], to fields: [String]) -> [String: Any] {
    guard !fields.isEmpty else { return doc }
    return doc.filter { fields.contains($0.key) || $0.key == "identifier" }
  }

  private func encode(_ object: Any) -> Data {
    (try? JSONSerialization.data(withJSONObject: object)) ?? Data()
  }

  // MARK: - Fixtures

  /// `ymsb2006-07-03.flac16` -> `Ymsb`: fixture files are named by the item's prefix.
  private static func fixtureSuffix(_ identifier: String) -> String {
    let prefix = identifier.prefix { $0.isLetter }
    return prefix.prefix(1).uppercased() + prefix.dropFirst()
  }

  private static func fixtureData(_ name: String) -> Data? {
    let dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    return try? Data(contentsOf: dir.appendingPathComponent("MockResponse/\(name)"))
  }

  private static func json(_ name: String) -> Any? {
    fixtureData(name).flatMap { try? JSONSerialization.jsonObject(with: $0) }
  }
}
