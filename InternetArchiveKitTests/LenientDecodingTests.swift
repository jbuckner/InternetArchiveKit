//
//  LenientDecodingTests.swift
//  InternetArchiveKitTests
//
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import URLSessionMock
import XCTest

@testable import InternetArchiveKit

final class LenientValueTests: XCTestCase {

  private func value(_ json: String) throws -> LenientValue {
    struct Box: Decodable { let v: LenientValue }
    let data = Data("{\"v\": \(json)}".utf8)
    return try JSONDecoder().decode(Box.self, from: data).v
  }

  func testShapesDecodeToStrings() throws {
    XCTAssertEqual(try value("\"abc\"").strings, ["abc"])
    XCTAssertEqual(try value("1952").strings, ["1952"])
    XCTAssertEqual(try value("1740.04").strings, ["1740.04"])
    XCTAssertEqual(try value("true").strings, ["true"])
    XCTAssertEqual(try value("[\"a\", 2, false]").strings, ["a", "2", "false"])
  }

  func testUnknownShapesNeverThrow() throws {
    XCTAssertEqual(try value("null").strings, [])
    XCTAssertEqual(try value("{\"a\": 1}").strings, [])
    XCTAssertEqual(try value("[{\"a\": 1}, \"keep\", null]").strings, ["keep"])
    XCTAssertEqual(try value("[]").strings, [])
  }

  func testFirstSkipsBlanksAndTrims() {
    XCTAssertEqual(LenientValue(strings: ["", "  ", " x "]).first, "x")
    XCTAssertNil(LenientValue(strings: ["", " "]).first)
    XCTAssertNil(LenientValue(strings: []).first)
  }

  func testYear() {
    XCTAssertEqual(LenientValue(strings: ["1952"]).year, 1952)
    XCTAssertEqual(LenientValue(strings: ["1952-06-01T00:00:00Z"]).year, 1952)
    XCTAssertNil(LenientValue(strings: ["195"]).year)
    XCTAssertNil(LenientValue(strings: ["c1952"]).year)
    XCTAssertNil(LenientValue(strings: ["abcd"]).year)
  }

  func testIntAndDouble() {
    XCTAssertEqual(LenientValue(strings: ["42"]).int, 42)
    XCTAssertEqual(LenientValue(strings: ["12.0"]).int, 12)
    XCTAssertNil(LenientValue(strings: ["12.5"]).int)
    XCTAssertNil(LenientValue(strings: ["x"]).int)
    XCTAssertEqual(LenientValue(strings: ["1740.04"]).double, 1740.04)
    XCTAssertNil(LenientValue(strings: ["nan"]).double)
  }

  func testBool() {
    for text in ["true", "TRUE", "yes", "1"] {
      XCTAssertEqual(LenientValue(strings: [text]).bool, true, text)
    }
    for text in ["false", "no", "0"] {
      XCTAssertEqual(LenientValue(strings: [text]).bool, false, text)
    }
    XCTAssertNil(LenientValue(strings: ["maybe"]).bool)
    XCTAssertNil(LenientValue(strings: []).bool)
  }

  func testSeconds() {
    XCTAssertEqual(LenientValue(strings: ["1740.04"]).seconds, 1740.04)
    XCTAssertEqual(LenientValue(strings: ["0"]).seconds, 0)
    XCTAssertEqual(LenientValue(strings: ["11:03"]).seconds, 663)
    XCTAssertEqual(LenientValue(strings: ["1:02:03"]).seconds, 3723)
    XCTAssertEqual(LenientValue(strings: ["01:02.5"]).seconds, 62.5)
    XCTAssertNil(LenientValue(strings: ["1:2:3:4"]).seconds)
    XCTAssertNil(LenientValue(strings: ["1.5:30"]).seconds)
    XCTAssertNil(LenientValue(strings: ["a:30"]).seconds)
    XCTAssertNil(LenientValue(strings: ["-5"]).seconds)
    XCTAssertNil(LenientValue(strings: [":"]).seconds)
  }

  func testRoundTrip() throws {
    let original = LenientValue(strings: ["a", "b"])
    let data = try JSONEncoder().encode(original)
    XCTAssertEqual(try JSONDecoder().decode(LenientValue.self, from: data), original)
  }
}

/// Decoding into caller-defined types, with unedited archive.org responses
/// (`MockResponse/lenientSearch.json`, `MockResponse/lenientMetadata.json`).
final class CallerTypeDecodingTests: XCTestCase {

  private struct MovieDoc: Decodable, Sendable {
    let identifier: String
    let title: LenientValue?
    let year: LenientValue?
    let downloads: LenientValue?
    let runtime: LenientValue?
    let creator: LenientValue?
  }

  private struct Detail: Decodable, Sendable {
    struct File: Decodable, Sendable {
      let name: String
      let length: LenientValue?
      let size: LenientValue?
      let source: LenientValue?
    }
    struct Meta: Decodable, Sendable {
      let identifier: String
      let licenseurl: LenientValue?
      let runtime: LenientValue?
      let collection: LenientValue?
      let isDark: LenientValue?
      enum CodingKeys: String, CodingKey {
        case identifier, licenseurl, runtime, collection
        case isDark = "is_dark"
      }
    }
    let metadata: Meta
    let files: [File]
  }

  private func fixture(_ name: String) throws -> Data {
    let dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    return try Data(contentsOf: dir.appendingPathComponent("MockResponse/\(name)"))
  }

  private func archive(serving data: Data, at url: URL?, status: Int = 200)
    -> InternetArchive
  {
    let generator = InternetArchive.URLGenerator()
    if let url {
      URLSession.mockEndpoints = [
        url: BasicEndpointMock(status: status, url: url, body: data, headers: nil, error: nil)
      ]
    }
    return InternetArchive(urlGenerator: generator, urlSession: URLSession.mock)
  }

  func testSearchDecodesIntoCallerType() async throws {
    let generator = InternetArchive.URLGenerator()
    let query = InternetArchive.Query(clauses: ["collection": "prelinger"])
    let url = try XCTUnwrap(
      generator.generateSearchUrl(
        query: query, page: 1, rows: 3, fields: ["identifier", "title"], sortFields: [],
        additionalQueryParams: []))
    let ia = archive(serving: try fixture("lenientSearch.json"), at: url)

    let results = try await ia.search(
      query: query, page: 1, rows: 3, fields: ["identifier", "title"],
      documentType: MovieDoc.self)

    XCTAssertEqual(results.numFound, 10461)
    XCTAssertEqual(results.start, 0)
    XCTAssertEqual(
      results.docs.map(\.identifier), ["AboutBan1935", "Doctorin1946", "HealthYo1953"])
    XCTAssertEqual(results.docs[0].year?.year, 1935)
    XCTAssertEqual(results.docs[0].downloads?.int, 27_201_041)
    XCTAssertEqual(results.docs[0].runtime?.seconds, 663)
    XCTAssertEqual(results.docs[0].creator?.first, "Castle Films")
  }

  func testMetadataDecodesIntoCallerType() async throws {
    let url = try XCTUnwrap(
      InternetArchive.URLGenerator().generateMetadataUrl(identifier: "AboutBan1935"))
    let ia = archive(serving: try fixture("lenientMetadata.json"), at: url)

    let detail = try await ia.metadata(identifier: "AboutBan1935", as: Detail.self)

    XCTAssertEqual(detail.metadata.identifier, "AboutBan1935")
    XCTAssertEqual(
      detail.metadata.licenseurl?.first, "http://creativecommons.org/licenses/publicdomain/")
    XCTAssertEqual(detail.metadata.runtime?.seconds, 663)
    XCTAssertNil(detail.metadata.isDark)
    // lengths arrive as "664.29" on some files and "11:03" on others
    let lengths = detail.files.compactMap { $0.length?.seconds }
    XCTAssertTrue(lengths.contains(664.29))
    XCTAssertTrue(lengths.contains(663))
    XCTAssertEqual(detail.files.first { $0.name == "AboutBan1935.asr.srt" }?.size?.int, 0)
  }

  func testMetadataSurfacesHttpError() async throws {
    let url = try XCTUnwrap(InternetArchive.URLGenerator().generateMetadataUrl(identifier: "nope"))
    let ia = archive(serving: Data("<html/>".utf8), at: url, status: 500)
    do {
      _ = try await ia.metadata(identifier: "nope", as: Detail.self)
      XCTFail("expected an error")
    } catch {
      XCTAssertEqual(
        error as? InternetArchive.InternetArchiveError, .httpError(statusCode: 500))
    }
  }

  func testMetadataSurfacesApiErrorEnvelope() async throws {
    let url = try XCTUnwrap(InternetArchive.URLGenerator().generateMetadataUrl(identifier: "bad"))
    let ia = archive(serving: Data("{\"error\": \"nope\"}".utf8), at: url)
    do {
      _ = try await ia.metadata(identifier: "bad", as: Detail.self)
      XCTFail("expected an error")
    } catch {
      XCTAssertEqual(error as? InternetArchive.InternetArchiveError, .apiError(message: "nope"))
    }
  }

  func testDecodingIsAvailableThroughTheProtocol() {
    let ia: any InternetArchiveDecoding = InternetArchive()
    XCTAssertNotNil(ia)
  }
}
