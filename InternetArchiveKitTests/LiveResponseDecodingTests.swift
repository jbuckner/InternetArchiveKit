//
//  LiveResponseDecodingTests.swift
//  InternetArchiveKitTests
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import XCTest
import ZippyJSON

@testable import InternetArchiveKit

/// Decodes unedited `archive.org/metadata/<id>` responses and checks the values against the
/// raw JSON they came from.
///
/// A hand-written fixture can't catch the failure that matters here: a field whose Swift name
/// doesn't line up with its wire key still decodes fine, it just silently comes back `nil`.
/// Comparing against the source JSON is what surfaces that.
class LiveResponseDecodingTests: XCTestCase {

  /// Same configuration `InternetArchive` uses for real responses.
  private func decoder() -> ZippyJSONDecoder {
    let decoder = ZippyJSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }

  private func fixture(_ name: String) throws -> Data {
    let url = try XCTUnwrap(
      Bundle.module.url(forResource: name, withExtension: "json"),
      "missing fixture \(name).json")
    return try Data(contentsOf: url)
  }

  private func rawMetadata(_ name: String) throws -> [String: Any] {
    let json = try JSONSerialization.jsonObject(with: try fixture(name)) as? [String: Any]
    return try XCTUnwrap(json?["metadata"] as? [String: Any])
  }

  private func item(_ name: String) throws -> InternetArchive.Item {
    try decoder().decode(InternetArchive.Item.self, from: try fixture(name))
  }

  // MARK: - etree (sci2007-07-28.Schoeps)

  func testDecodesEtreeItem() throws {
    let item = try item("liveEtreeItem")
    let metadata = try XCTUnwrap(item.metadata)

    XCTAssertEqual(metadata.identifier, "sci2007-07-28.Schoeps")
    XCTAssertTrue(metadata.mediatype?.value == .etree)
    XCTAssertEqual(metadata.venue?.value, "Horning's Hideout")
    XCTAssertEqual(metadata.coverage?.value, "North Plains, OR")
    XCTAssertNotNil(metadata.addeddate?.value)
    XCTAssertNotNil(metadata.publicdate?.value)

    // this item's runtime is "245 Mins.", which is why the field stays a string
    XCTAssertEqual(metadata.runtime?.value, "245 Mins.")
    XCTAssertNil(metadata.runtimeInterval)

    // top-level fields
    XCTAssertEqual(item.created?.value?.timeIntervalSince1970, 1_787_425_053)
    XCTAssertEqual(item.itemLastUpdated?.value?.timeIntervalSince1970, 1_581_697_658)
    XCTAssertEqual(item.serversUnavailable, true)
    XCTAssertEqual(
      item.alternateLocations?.servers?.first?.server, "dn720306.ca.archive.org")
    XCTAssertEqual(
      item.alternateLocations?.workable?.first?.dir, "/0/items/sci2007-07-28.Schoeps")

    // files
    let files = try XCTUnwrap(item.files)
    XCTAssertFalse(files.isEmpty)
    let flac = try XCTUnwrap(files.first { $0.format?.value == .flac })
    XCTAssertTrue(flac.source?.value == .original)
    XCTAssertNotNil(flac.mtime?.value)
    XCTAssertNotNil(flac.length?.value)

    let torrent = try XCTUnwrap(files.first { $0.format?.value == .archiveBitTorrent })
    XCTAssertNotNil(torrent.btih?.value)
  }

  /// Every `format` and `source` in the fixture should map to a documented case. An
  /// `.unknown` here means the vocabulary is missing a value the Archive really serves.
  func testEtreeFormatsAndSourcesAreAllKnown() throws {
    let item = try item("liveEtreeItem")
    for file in try XCTUnwrap(item.files) {
      if let format = file.format?.value {
        XCTAssertNotNil(format.known, "unmapped file format: \(format.rawValue)")
      }
      if let source = file.source?.value {
        XCTAssertNotNil(source.known, "unmapped file source: \(source.rawValue)")
      }
    }
  }

  // MARK: - texts (goody)

  func testDecodesTextsItem() throws {
    let item = try item("liveTextsItem")
    let metadata = try XCTUnwrap(item.metadata)

    XCTAssertEqual(metadata.identifier, "goody")
    XCTAssertTrue(metadata.mediatype?.value == .texts)
    XCTAssertEqual(metadata.language?.value, "English")
    XCTAssertEqual(metadata.sponsor?.value, "Brigham Young University-Idaho")
    XCTAssertEqual(metadata.scanningcenter?.value, "rexburg")
    XCTAssertEqual(metadata.ppi?.value, 400)
    XCTAssertEqual(metadata.imagecount?.value, 196)
    XCTAssertEqual(metadata.foldoutcount?.value, 0)
    XCTAssertEqual(metadata.repubState?.value, 4)
    XCTAssertEqual(metadata.repubSeconds?.value, 5526)
    XCTAssertEqual(metadata.camera?.value, "Canon EOS 5D Mark II")
    XCTAssertEqual(metadata.operator?.value, "scanner-byui-01@archive.org")
    XCTAssertEqual(metadata.bookplateleaf?.value, "0003")
    XCTAssertEqual(metadata.invoice?.value, "83")
    XCTAssertEqual(metadata.scanfee?.value, "100")

    // hyphenated wire keys, the ones an explicit CodingKeys exists for
    XCTAssertTrue(metadata.pageProgression?.value == .leftToRight)
    XCTAssertEqual(metadata.identifierArk?.value, "ark:/13960/t52g1kj44")
    XCTAssertEqual(
      metadata.identifierAccess?.value?.absoluteString, "http://archive.org/details/goody")
    let external = try XCTUnwrap(metadata.externalIdentifier?.value)
    XCTAssertEqual(external.scheme, "lcp")
    XCTAssertTrue(external.value.hasPrefix("goody:epub:"))

    // compact timestamps, unparseable before this change
    XCTAssertNotNil(metadata.scandate?.value)
    XCTAssertNotNil(metadata.republisherDate?.value)
    XCTAssertNotNil(metadata.sponsordate?.value)
  }

  // MARK: - movies (FRANCE24_20241031_063000)

  func testDecodesMoviesItem() throws {
    let item = try item("liveMoviesItem")
    let metadata = try XCTUnwrap(item.metadata)

    XCTAssertTrue(metadata.mediatype?.value == .movies)
    XCTAssertTrue(metadata.sound?.value == .sound)
    XCTAssertEqual(metadata.color?.value, "color")
    XCTAssertEqual(metadata.audioCodec?.value, "aac")
    XCTAssertEqual(metadata.videoCodec?.value, "h264")
    XCTAssertEqual(metadata.audioSampleRate?.value, 44100)
    XCTAssertEqual(metadata.framesPerSecond?.value, 30)
    XCTAssertEqual(metadata.sourcePixelWidth?.value, 1280)
    XCTAssertEqual(metadata.sourcePixelHeight?.value, 720)
    XCTAssertEqual(metadata.tuner?.value, "Channel IPTV")
    XCTAssertEqual(metadata.utcOffset?.value, 100)

    // "16:9" would come back as 969 seconds through IATimeInterval
    let aspect = try XCTUnwrap(metadata.aspectRatio?.value)
    XCTAssertEqual(aspect.width, 16)
    XCTAssertEqual(aspect.height, 9)

    // "00:30:59", one of the runtimes that is a real duration
    XCTAssertEqual(metadata.runtime?.value, "00:30:59")
    XCTAssertEqual(try XCTUnwrap(metadata.runtimeInterval), 1859, accuracy: 0.5)

    // "no", which IABool only understands after this change
    XCTAssertEqual(metadata.closedCaptioning?.value, false)
    // hyphenated key
    XCTAssertEqual(metadata.accessRestrictedItem?.value, true)

    XCTAssertNotNil(metadata.startTime?.value)
    XCTAssertNotNil(metadata.stopTime?.value)
    XCTAssertNotNil(metadata.startLocaltime?.value)

    let video = try XCTUnwrap(try XCTUnwrap(item.files).first { $0.format?.value == .h264 })
    XCTAssertEqual(video.private?.value, true)
    XCTAssertEqual(video.width?.value, 1280)
  }

  // MARK: - collection (etree)

  func testDecodesCollectionItem() throws {
    let item = try item("liveCollectionItem")
    let metadata = try XCTUnwrap(item.metadata)

    XCTAssertEqual(metadata.identifier, "etree")
    XCTAssertTrue(metadata.mediatype?.value == .collection)
    XCTAssertEqual(metadata.titleMessage?.value, "Free Music")
    XCTAssertEqual(metadata.numStaffPicks?.value, 20)
    XCTAssertEqual(metadata.numTopBa?.value, 5)
    XCTAssertEqual(metadata.derivetorrents?.value, false)
    XCTAssertEqual(metadata.noarchivetorrent?.value, true)
    XCTAssertEqual(metadata.showSearchByYear?.value, true)
    XCTAssertEqual(metadata.showRelatedMusicByTrack?.value, true)
    XCTAssertNotNil(metadata.filesxml?.value)

    // the tagged-blob field
    let curation = try XCTUnwrap(metadata.curation?.value)
    XCTAssertEqual(curation.curator, "tracey pooh")
    XCTAssertTrue(curation.state == .undark)
    XCTAssertNotNil(curation.date)

    // repeated fields still collect into `values`
    XCTAssertGreaterThan(try XCTUnwrap(metadata.updater?.values).count, 1)
    XCTAssertGreaterThan(try XCTUnwrap(metadata.contributor?.values).count, 1)
  }

  // MARK: - Coverage of the raw payloads

  /// Walks every key in each fixture's `metadata` object and reports the ones the model
  /// drops. Not a failure on its own, the schema is bigger than any model, but it keeps the
  /// gap visible instead of letting it grow unnoticed.
  func testReportsUnmodelledMetadataKeys() throws {
    let modelled = Set(
      InternetArchive.ItemMetadata.CodingKeys.allCases.map(\.rawValue))
    var missing: Set<String> = []
    for name in ["liveEtreeItem", "liveTextsItem", "liveMoviesItem", "liveCollectionItem"] {
      for key in try rawMetadata(name).keys where !modelled.contains(Self.camelCased(key)) {
        missing.insert(key)
      }
    }
    if !missing.isEmpty {
      print("metadata keys present in fixtures but not on ItemMetadata: \(missing.sorted())")
    }
  }

  /// The decoder converts wire keys before looking them up, so the raw JSON keys have to go
  /// through the same conversion to be compared against `CodingKeys`. Hyphenated keys come
  /// out unchanged, which is exactly why those need an explicit raw value on the enum.
  private static func camelCased(_ key: String) -> String {
    let parts = key.split(separator: "_", omittingEmptySubsequences: false)
    guard parts.count > 1 else { return key }
    return parts[0] + parts.dropFirst().map { $0.capitalized }.joined()
  }
}
