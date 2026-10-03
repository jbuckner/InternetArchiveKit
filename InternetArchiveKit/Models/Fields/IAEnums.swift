//
//  IAEnums.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   The kind of content an item holds.

   See the Internet Archive's
   [metadata schema](https://archive.org/developers/metadata-schema/mediatype.html).
   */
  public enum MediaType: String, IAEnumCase {
    case account
    case audio
    case collection
    case data
    case etree
    case image
    case movies
    case software
    case texts
    case web
  }

  /**
   Where a file came from.

   `original` files were uploaded, `derivative` files were generated from an original by the
   Archive's derive process, and `metadata` files describe the item itself.
   */
  public enum FileSource: String, IAEnumCase {
    case original
    case derivative
    case metadata
  }

  /**
   The format of a file within an item.

   The Archive's format list is long and grows over time, so this covers the formats seen in
   practice rather than all of them. Anything missing still decodes: `IAEnumValue` keeps the
   raw string as `.unknown`, so no data is lost.
   */
  public enum FileFormat: String, IAEnumCase {
    // audio
    case flac = "Flac"
    case flac24 = "24bit Flac"
    case flacFingerPrint = "Flac FingerPrint"
    case shorten = "Shorten"
    case wave = "WAVE"
    case oggVorbis = "Ogg Vorbis"
    case vbrMP3 = "VBR MP3"
    case mp3At64Kbps = "64Kbps MP3"
    case mp3At128Kbps = "128Kbps MP3"
    case columbiaPeaks = "Columbia Peaks"
    case spectrogram = "Spectrogram"
    case essentiaHighGZ = "Essentia High GZ"
    case essentiaLowGZ = "Essentia Low GZ"

    // video
    case h264 = "h.264"
    case h264IA = "h.264 IA"
    case mpeg1 = "MPEG1"
    case mpeg2 = "MPEG2"
    case mpeg4 = "MPEG4"
    case mpeg512Kb = "512Kb MPEG4"

    // images
    case jpeg = "JPEG"
    case jpegThumb = "JPEG Thumb"
    case png = "PNG"
    case animatedGIF = "Animated GIF"
    case thumbnail = "Thumbnail"
    case itemTile = "Item Tile"
    case itemImage = "Item Image"
    case emulatorScreenshot = "Emulator Screenshot"

    // texts and books
    case textPDF = "Text PDF"
    case additionalTextPDF = "Additional Text PDF"
    case epub = "EPUB"
    case abbyyGZ = "Abbyy GZ"
    case djvuTXT = "DjVuTXT"
    case djvuXML = "Djvu XML"
    case hOCR = "hOCR"
    case chOCR = "chOCR"
    case ocrPageIndex = "OCR Page Index"
    case ocrSearchText = "OCR Search Text"
    case scandata = "Scandata"
    case pageNumbersJSON = "Page Numbers JSON"
    case clothCoverDetectionLog = "Cloth Cover Detection Log"
    case singlePageOriginalJP2Tar = "Single Page Original JP2 Tar"
    case singlePageProcessedJP2ZIP = "Single Page Processed JP2 ZIP"

    // web archives
    case webARChiveGZ = "Web ARChive GZ"
    case itemCDXIndex = "Item CDX Index"
    case itemCDXMetaIndex = "Item CDX Meta-Index"
    case warcCDXIndex = "WARC CDX Index"
    case warcHostLinksGZ = "WARC HostLinks GZ"

    // archives and metadata
    case metadata = "Metadata"
    case metadataLog = "Metadata Log"
    case extraMetadataJSON = "Extra Metadata JSON"
    case checksums = "Checksums"
    case archiveBitTorrent = "Archive BitTorrent"
    case log = "Log"
    case text = "Text"
    case json = "JSON"
    case jsonGZ = "JSON GZ"
    case commaSeparatedValues = "Comma-Separated Values"
    case zip = "ZIP"
    case gzip = "GZIP"
    case bzip2 = "BZIP2"
    case rar = "RAR"
    case androidPackageArchive = "Android Package Archive"

    /// The Archive's literal `"Unknown"` format, distinct from `IAEnumValue.unknown`,
    /// which means this library didn't recognize the value at all.
    case unknownFormat = "Unknown"
  }

  /// The direction pages turn in the book reader.
  public enum PageProgression: String, IAEnumCase {
    /// left to right
    case leftToRight = "lr"
    /// right to left
    case rightToLeft = "rl"
  }

  /// Whether a recording carries audio.
  public enum Sound: String, IAEnumCase {
    case sound
    case silent
  }

  /// The physical state of the media an item was captured from.
  public enum Condition: String, IAEnumCase {
    case mint = "Mint"
    case nearMint = "Near Mint"
    case veryGood = "Very Good"
    case good = "Good"
    case fair = "Fair"
    case worn = "Worn"
    case poor = "Poor"
    case fragile = "Fragile"
    case incomplete = "Incomplete"
  }

  /// The state of an item's artwork and accompanying materials.
  public enum ConditionVisual: String, IAEnumCase {
    case mint = "Mint"
    case nearMint = "Near Mint"
    case veryGood = "Very Good"
    case good = "Good"
    case fair = "Fair"
    case worn = "Worn"
    case poor = "Poor"
    case fragile = "Fragile"
    case incomplete = "Incomplete"
    case none = "None"
    case unknown = "Unknown"
  }

  /// The book reader's default display mode.
  public enum BookReaderDefaults: String, IAEnumCase {
    case onePage = "mode/1up"
    case twoPage = "mode/2up"
    case thumbnails = "mode/thumb"
  }

  /// The default sort order for a collection's details page. A leading `-` reverses the sort.
  public enum SortBy: String, IAEnumCase {
    case addeddate
    case addeddateDescending = "-addeddate"
    case creatorSorter
    case creatorSorterDescending = "-creatorSorter"
    case date
    case dateDescending = "-date"
    case downloads
    case downloadsDescending = "-downloads"
    case publicdate
    case publicdateDescending = "-publicdate"
    case reviewdate
    case reviewdateDescending = "-reviewdate"
    case titleSorter
    case titleSorterDescending = "-titleSorter"
  }

  /// The curation state recorded in an item's `curation` field.
  public enum CurationState: String, IAEnumCase {
    case dark
    case undark = "un-dark"
    case freeze
  }
}
