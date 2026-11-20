//
//  ItemMetadata.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   Internet Archive Item Metadata

   This will be returned from `itemDetail()` and `search()` requests.

   **Note**: The properties are all type `ModelField<T>` **except** `identifier`, which is a `String`.
   This means you need to access all values by their `.value` or `.values` properties, except for `identifier`,
   which you can access directly.

   **Some Background**: All other fields can be a string or array of strings so we can't access them
   directly. See the `ModelField` class for a more thorough explanation.

   For example:
   ```
   let metadata = ItemMetadata(...some metadata...)
   metadata.identifier = "SCIRedRocksConcert" // `identifier` is always a String
   metadata.venue.value = "Red Rocks" // other fields can be a string or array of strings so you can't access directly
   ```

   Fields with a documented set of allowed values, like `mediatype`, use `IAEnum` and compare
   against a case or the raw string:
   ```
   metadata.mediatype?.value == .etree
   metadata.mediatype?.value == "etree"
   ```

   See the Internet Archive's
   [metadata schema](https://archive.org/developers/metadata-schema/index.html)
   for a description of the properties.

   **Note**: This is not an exhaustive list of metadata properties. It covers the public schema
   plus the internal fields that appear in real responses. If you need some that are missing,
   please open a pull request.
   */
  public struct ItemMetadata: Codable, Sendable {
    public let identifier: String
    public let accessRestricted: ModelField<IABool>?
    public let accessRestrictedItem: ModelField<IABool>?
    public let addeddate: ModelField<IADate>?
    public let adder: ModelField<IAString>?
    public let adminCollection: ModelField<IABool>?
    public let aspectRatio: ModelField<IAAspectRatio>?
    public let audioCodec: ModelField<IAString>?
    public let audioSampleRate: ModelField<IAInt>?
    public let avgRating: ModelField<IADouble>?
    public let backupLocation: ModelField<IAString>?
    public let bookplateleaf: ModelField<IAString>?
    public let bookreaderDefaults: ModelField<IAEnum<BookReaderDefaults>>?
    public let boxid: ModelField<IAString>?
    public let callNumber: ModelField<IAString>?
    public let camera: ModelField<IAString>?
    public let ccnum: ModelField<IAString>?
    public let closedCaptioning: ModelField<IABool>?
    public let collection: ModelField<IAString>?
    public let collectionSize: ModelField<IAInt>?
    public let collectionsRaw: ModelField<IAString>?
    public let color: ModelField<IAString>?
    public let condition: ModelField<IAEnum<Condition>>?
    public let conditionVisual: ModelField<IAEnum<ConditionVisual>>?
    public let contributor: ModelField<IAString>?
    public let coverage: ModelField<IAString>?
    public let creator: ModelField<IAString>?
    public let creatorAltScript: ModelField<IAString>?
    public let curation: ModelField<IACuration>?
    public let date: ModelField<IADate>?
    public let derivetorrents: ModelField<IABool>?
    public let description: ModelField<IAString>?
    public let discs: ModelField<IAString>?
    public let downloads: ModelField<IAInt>?
    public let externalIdentifier: ModelField<IAExternalIdentifier>?
    public let filesCount: ModelField<IAInt>?
    public let filesxml: ModelField<IAString>?
    public let firstfiledate: ModelField<IADate>?
    public let foldoutcount: ModelField<IAInt>?
    public let format: ModelField<IAEnum<FileFormat>>?
    public let framesPerSecond: ModelField<IADouble>?
    public let genre: ModelField<IAString>?
    public let geoRestricted: ModelField<IAString>?
    public let hasMp3: ModelField<IAString>?
    public let hidden: ModelField<IABool>?
    public let homepage: ModelField<IAURL>?
    public let identifierAccess: ModelField<IAURL>?
    public let identifierArk: ModelField<IAString>?
    public let identifierBib: ModelField<IAString>?
    public let imagecount: ModelField<IAInt>?
    public let indexdate: ModelField<IADate>?
    public let indexflag: ModelField<IAString>?
    public let invoice: ModelField<IAString>?
    public let isbn: ModelField<IAString>?
    public let isDark: ModelField<IAString>?
    public let issn: ModelField<IAString>?
    public let itemCount: ModelField<IAInt>?
    public let itemSize: ModelField<IAInt>?
    public let language: ModelField<IAString>?
    public let lastfiledate: ModelField<IADate>?
    public let lccn: ModelField<IAString>?
    public let licenseurl: ModelField<IAURL>?
    public let limflag: ModelField<IAString>?
    public let lineage: ModelField<IAString>?
    public let md5s: ModelField<IAString>?
    public let mediatype: ModelField<IAEnum<MediaType>>?
    public let month: ModelField<IAInt>?
    public let nextItem: ModelField<IAString>?
    public let noarchivetorrent: ModelField<IABool>?
    public let noindex: ModelField<IABool>?
    public let notes: ModelField<IAString>?
    public let numericId: ModelField<IAInt>?
    public let numRecentReviews: ModelField<IAInt>?
    public let numReviews: ModelField<IAInt>?
    public let numStaffPicks: ModelField<IAInt>?
    public let numTopBa: ModelField<IAInt>?
    public let numTopDl: ModelField<IAInt>?
    public let oaiUpdatedate: ModelField<IADate>?
    public let oclcId: ModelField<IAString>?
    public let ocr: ModelField<IAString>?
    public let ocrDetectedLang: ModelField<IAString>?
    public let ocrDetectedLangConf: ModelField<IADouble>?
    public let ocrDetectedScript: ModelField<IAString>?
    public let ocrDetectedScriptConf: ModelField<IADouble>?
    public let ocrModuleVersion: ModelField<IAString>?
    public let ocrParameters: ModelField<IAString>?
    public let openlibraryAuthor: ModelField<IAString>?
    public let openlibraryEdition: ModelField<IAString>?
    public let openlibrarySubject: ModelField<IAString>?
    public let openlibraryWork: ModelField<IAString>?
    public let `operator`: ModelField<IAString>?
    public let pageNumberConfidence: ModelField<IADouble>?
    public let pageNumberModuleVersion: ModelField<IAString>?
    public let pageProgression: ModelField<IAEnum<PageProgression>>?
    public let pdfModuleVersion: ModelField<IAString>?
    public let pick: ModelField<IAString>?
    public let possibleCopyrightStatus: ModelField<IAString>?
    public let ppi: ModelField<IAInt>?
    public let previousItem: ModelField<IAString>?
    public let `public`: ModelField<IAString>?
    public let publicdate: ModelField<IADate>?
    public let publicFormat: ModelField<IAString>?
    public let publisher: ModelField<IAString>?
    public let relatedCollection: ModelField<IAString>?
    public let relatedExternalId: ModelField<IAString>?
    public let republisher: ModelField<IAString>?
    public let republisherDate: ModelField<IADate>?
    public let republisherOperator: ModelField<IAString>?
    public let republisherTime: ModelField<IAInt>?
    public let repubSeconds: ModelField<IAInt>?
    public let repubState: ModelField<IAInt>?
    public let reviewdate: ModelField<IADate>?
    public let rights: ModelField<IAString>?
    public let runtime: ModelField<IAString>?
    public let scandate: ModelField<IADate>?
    public let scanfee: ModelField<IAString>?
    public let scanner: ModelField<IAString>?
    public let scanningcenter: ModelField<IAString>?
    public let shndiscs: ModelField<IAString>?
    public let showRelatedMusicByTrack: ModelField<IABool>?
    public let showSearchByDate: ModelField<IABool>?
    public let showSearchByYear: ModelField<IABool>?
    public let size: ModelField<IAString>?
    public let sortBy: ModelField<IAEnum<SortBy>>?
    public let sound: ModelField<IAEnum<Sound>>?
    public let source: ModelField<IAString>?
    public let sourcePixelHeight: ModelField<IAInt>?
    public let sourcePixelWidth: ModelField<IAInt>?
    public let sponsor: ModelField<IAString>?
    public let sponsordate: ModelField<IADate>?
    public let spotlightIdentifier: ModelField<IAString>?
    public let startLocaltime: ModelField<IADate>?
    public let startTime: ModelField<IADate>?
    public let stopTime: ModelField<IADate>?
    public let strippedTags: ModelField<IAString>?
    public let subject: ModelField<IAString>?
    public let summary: ModelField<IAString>?
    public let taper: ModelField<IAString>?
    public let tasks: ModelField<IAString>?
    public let title: ModelField<IAString>?
    public let titleAltScript: ModelField<IAString>?
    public let titleMessage: ModelField<IAString>?
    public let transferer: ModelField<IAString>?
    public let tuner: ModelField<IAString>?
    public let type: ModelField<IAString>?
    public let updated: ModelField<IAString>?
    public let updatedate: ModelField<IADate>?
    public let updater: ModelField<IAString>?
    public let uploader: ModelField<IAString>?
    public let utcOffset: ModelField<IAInt>?
    public let venue: ModelField<IAString>?
    public let videoCodec: ModelField<IAString>?
    public let volume: ModelField<IAString>?
    public let week: ModelField<IAInt>?
    public let year: ModelField<IAInt>?

    /// Spelled out rather than synthesized because the decoder's `.convertFromSnakeCase`
    /// strategy only rewrites underscores. Hyphenated keys like `identifier-access` reach
    /// the key lookup unchanged, so they'd never match a synthesized camelCase key.
    /// `CodingKeys` is all-or-nothing, hence the full list.
    enum CodingKeys: String, CodingKey, CaseIterable {
      case identifier
      case accessRestricted = "access-restricted"
      case accessRestrictedItem = "access-restricted-item"
      case addeddate
      case adder
      case adminCollection = "admin-collection"
      case aspectRatio
      case audioCodec
      case audioSampleRate
      case avgRating
      case backupLocation
      case bookplateleaf
      case bookreaderDefaults = "bookreader-defaults"
      case boxid
      case callNumber
      case camera
      case ccnum
      case closedCaptioning
      case collection
      case collectionSize
      case collectionsRaw
      case color
      case condition
      case conditionVisual = "condition-visual"
      case contributor
      case coverage
      case creator
      case creatorAltScript = "creator-alt-script"
      case curation
      case date
      case derivetorrents
      case description
      case discs
      case downloads
      case externalIdentifier = "external-identifier"
      case filesCount
      case filesxml
      case firstfiledate
      case foldoutcount
      case format
      case framesPerSecond
      case genre
      case geoRestricted
      case hasMp3
      case hidden
      case homepage
      case identifierAccess = "identifier-access"
      case identifierArk = "identifier-ark"
      case identifierBib = "identifier-bib"
      case imagecount
      case indexdate
      case indexflag
      case invoice
      case isbn
      case isDark
      case issn
      case itemCount
      case itemSize
      case language
      case lastfiledate
      case lccn
      case licenseurl
      case limflag
      case lineage
      case md5s
      case mediatype
      case month
      case nextItem
      case noarchivetorrent
      case noindex
      case notes
      case numericId
      case numRecentReviews
      case numReviews
      case numStaffPicks
      case numTopBa
      case numTopDl
      case oaiUpdatedate
      case oclcId = "oclc-id"
      case ocr
      case ocrDetectedLang
      case ocrDetectedLangConf
      case ocrDetectedScript
      case ocrDetectedScriptConf
      case ocrModuleVersion
      case ocrParameters
      case openlibraryAuthor
      case openlibraryEdition
      case openlibrarySubject
      case openlibraryWork
      case `operator`
      case pageNumberConfidence
      case pageNumberModuleVersion
      case pageProgression = "page-progression"
      case pdfModuleVersion
      case pick
      case possibleCopyrightStatus = "possible-copyright-status"
      case ppi
      case previousItem
      case `public`
      case publicdate
      case publicFormat = "public-format"
      case publisher
      case relatedCollection
      case relatedExternalId = "related-external-id"
      case republisher
      case republisherDate
      case republisherOperator
      case republisherTime
      case repubSeconds
      case repubState
      case reviewdate
      case rights
      case runtime
      case scandate
      case scanfee
      case scanner
      case scanningcenter
      case shndiscs
      case showRelatedMusicByTrack
      case showSearchByDate
      case showSearchByYear
      case size
      case sortBy = "sort-by"
      case sound
      case source
      case sourcePixelHeight
      case sourcePixelWidth
      case sponsor
      case sponsordate
      case spotlightIdentifier
      case startLocaltime
      case startTime
      case stopTime
      case strippedTags
      case subject
      case summary
      case taper
      case tasks
      case title
      case titleAltScript = "title-alt-script"
      case titleMessage
      case transferer
      case tuner
      case type
      case updated
      case updatedate
      case updater
      case uploader
      case utcOffset
      case venue
      case videoCodec
      case volume
      case week
      case year
    }

    /// Everything but `identifier` defaults to `nil`, so a test or a cache can build a
    /// partial item without naming all of the schema.
    ///
    /// Declared in the struct body on purpose: moving it to an extension would leave Swift
    /// synthesizing a memberwise init with this exact signature, which is a redeclaration.
    public init(
      identifier: String,
      accessRestricted: ModelField<IABool>? = nil,
      accessRestrictedItem: ModelField<IABool>? = nil,
      addeddate: ModelField<IADate>? = nil,
      adder: ModelField<IAString>? = nil,
      adminCollection: ModelField<IABool>? = nil,
      aspectRatio: ModelField<IAAspectRatio>? = nil,
      audioCodec: ModelField<IAString>? = nil,
      audioSampleRate: ModelField<IAInt>? = nil,
      avgRating: ModelField<IADouble>? = nil,
      backupLocation: ModelField<IAString>? = nil,
      bookplateleaf: ModelField<IAString>? = nil,
      bookreaderDefaults: ModelField<IAEnum<BookReaderDefaults>>? = nil,
      boxid: ModelField<IAString>? = nil,
      callNumber: ModelField<IAString>? = nil,
      camera: ModelField<IAString>? = nil,
      ccnum: ModelField<IAString>? = nil,
      closedCaptioning: ModelField<IABool>? = nil,
      collection: ModelField<IAString>? = nil,
      collectionSize: ModelField<IAInt>? = nil,
      collectionsRaw: ModelField<IAString>? = nil,
      color: ModelField<IAString>? = nil,
      condition: ModelField<IAEnum<Condition>>? = nil,
      conditionVisual: ModelField<IAEnum<ConditionVisual>>? = nil,
      contributor: ModelField<IAString>? = nil,
      coverage: ModelField<IAString>? = nil,
      creator: ModelField<IAString>? = nil,
      creatorAltScript: ModelField<IAString>? = nil,
      curation: ModelField<IACuration>? = nil,
      date: ModelField<IADate>? = nil,
      derivetorrents: ModelField<IABool>? = nil,
      description: ModelField<IAString>? = nil,
      discs: ModelField<IAString>? = nil,
      downloads: ModelField<IAInt>? = nil,
      externalIdentifier: ModelField<IAExternalIdentifier>? = nil,
      filesCount: ModelField<IAInt>? = nil,
      filesxml: ModelField<IAString>? = nil,
      firstfiledate: ModelField<IADate>? = nil,
      foldoutcount: ModelField<IAInt>? = nil,
      format: ModelField<IAEnum<FileFormat>>? = nil,
      framesPerSecond: ModelField<IADouble>? = nil,
      genre: ModelField<IAString>? = nil,
      geoRestricted: ModelField<IAString>? = nil,
      hasMp3: ModelField<IAString>? = nil,
      hidden: ModelField<IABool>? = nil,
      homepage: ModelField<IAURL>? = nil,
      identifierAccess: ModelField<IAURL>? = nil,
      identifierArk: ModelField<IAString>? = nil,
      identifierBib: ModelField<IAString>? = nil,
      imagecount: ModelField<IAInt>? = nil,
      indexdate: ModelField<IADate>? = nil,
      indexflag: ModelField<IAString>? = nil,
      invoice: ModelField<IAString>? = nil,
      isbn: ModelField<IAString>? = nil,
      isDark: ModelField<IAString>? = nil,
      issn: ModelField<IAString>? = nil,
      itemCount: ModelField<IAInt>? = nil,
      itemSize: ModelField<IAInt>? = nil,
      language: ModelField<IAString>? = nil,
      lastfiledate: ModelField<IADate>? = nil,
      lccn: ModelField<IAString>? = nil,
      licenseurl: ModelField<IAURL>? = nil,
      limflag: ModelField<IAString>? = nil,
      lineage: ModelField<IAString>? = nil,
      md5s: ModelField<IAString>? = nil,
      mediatype: ModelField<IAEnum<MediaType>>? = nil,
      month: ModelField<IAInt>? = nil,
      nextItem: ModelField<IAString>? = nil,
      noarchivetorrent: ModelField<IABool>? = nil,
      noindex: ModelField<IABool>? = nil,
      notes: ModelField<IAString>? = nil,
      numericId: ModelField<IAInt>? = nil,
      numRecentReviews: ModelField<IAInt>? = nil,
      numReviews: ModelField<IAInt>? = nil,
      numStaffPicks: ModelField<IAInt>? = nil,
      numTopBa: ModelField<IAInt>? = nil,
      numTopDl: ModelField<IAInt>? = nil,
      oaiUpdatedate: ModelField<IADate>? = nil,
      oclcId: ModelField<IAString>? = nil,
      ocr: ModelField<IAString>? = nil,
      ocrDetectedLang: ModelField<IAString>? = nil,
      ocrDetectedLangConf: ModelField<IADouble>? = nil,
      ocrDetectedScript: ModelField<IAString>? = nil,
      ocrDetectedScriptConf: ModelField<IADouble>? = nil,
      ocrModuleVersion: ModelField<IAString>? = nil,
      ocrParameters: ModelField<IAString>? = nil,
      openlibraryAuthor: ModelField<IAString>? = nil,
      openlibraryEdition: ModelField<IAString>? = nil,
      openlibrarySubject: ModelField<IAString>? = nil,
      openlibraryWork: ModelField<IAString>? = nil,
      `operator`: ModelField<IAString>? = nil,
      pageNumberConfidence: ModelField<IADouble>? = nil,
      pageNumberModuleVersion: ModelField<IAString>? = nil,
      pageProgression: ModelField<IAEnum<PageProgression>>? = nil,
      pdfModuleVersion: ModelField<IAString>? = nil,
      pick: ModelField<IAString>? = nil,
      possibleCopyrightStatus: ModelField<IAString>? = nil,
      ppi: ModelField<IAInt>? = nil,
      previousItem: ModelField<IAString>? = nil,
      `public`: ModelField<IAString>? = nil,
      publicdate: ModelField<IADate>? = nil,
      publicFormat: ModelField<IAString>? = nil,
      publisher: ModelField<IAString>? = nil,
      relatedCollection: ModelField<IAString>? = nil,
      relatedExternalId: ModelField<IAString>? = nil,
      republisher: ModelField<IAString>? = nil,
      republisherDate: ModelField<IADate>? = nil,
      republisherOperator: ModelField<IAString>? = nil,
      republisherTime: ModelField<IAInt>? = nil,
      repubSeconds: ModelField<IAInt>? = nil,
      repubState: ModelField<IAInt>? = nil,
      reviewdate: ModelField<IADate>? = nil,
      rights: ModelField<IAString>? = nil,
      runtime: ModelField<IAString>? = nil,
      scandate: ModelField<IADate>? = nil,
      scanfee: ModelField<IAString>? = nil,
      scanner: ModelField<IAString>? = nil,
      scanningcenter: ModelField<IAString>? = nil,
      shndiscs: ModelField<IAString>? = nil,
      showRelatedMusicByTrack: ModelField<IABool>? = nil,
      showSearchByDate: ModelField<IABool>? = nil,
      showSearchByYear: ModelField<IABool>? = nil,
      size: ModelField<IAString>? = nil,
      sortBy: ModelField<IAEnum<SortBy>>? = nil,
      sound: ModelField<IAEnum<Sound>>? = nil,
      source: ModelField<IAString>? = nil,
      sourcePixelHeight: ModelField<IAInt>? = nil,
      sourcePixelWidth: ModelField<IAInt>? = nil,
      sponsor: ModelField<IAString>? = nil,
      sponsordate: ModelField<IADate>? = nil,
      spotlightIdentifier: ModelField<IAString>? = nil,
      startLocaltime: ModelField<IADate>? = nil,
      startTime: ModelField<IADate>? = nil,
      stopTime: ModelField<IADate>? = nil,
      strippedTags: ModelField<IAString>? = nil,
      subject: ModelField<IAString>? = nil,
      summary: ModelField<IAString>? = nil,
      taper: ModelField<IAString>? = nil,
      tasks: ModelField<IAString>? = nil,
      title: ModelField<IAString>? = nil,
      titleAltScript: ModelField<IAString>? = nil,
      titleMessage: ModelField<IAString>? = nil,
      transferer: ModelField<IAString>? = nil,
      tuner: ModelField<IAString>? = nil,
      type: ModelField<IAString>? = nil,
      updated: ModelField<IAString>? = nil,
      updatedate: ModelField<IADate>? = nil,
      updater: ModelField<IAString>? = nil,
      uploader: ModelField<IAString>? = nil,
      utcOffset: ModelField<IAInt>? = nil,
      venue: ModelField<IAString>? = nil,
      videoCodec: ModelField<IAString>? = nil,
      volume: ModelField<IAString>? = nil,
      week: ModelField<IAInt>? = nil,
      year: ModelField<IAInt>? = nil
    ) {
      self.identifier = identifier
      self.accessRestricted = accessRestricted
      self.accessRestrictedItem = accessRestrictedItem
      self.addeddate = addeddate
      self.adder = adder
      self.adminCollection = adminCollection
      self.aspectRatio = aspectRatio
      self.audioCodec = audioCodec
      self.audioSampleRate = audioSampleRate
      self.avgRating = avgRating
      self.backupLocation = backupLocation
      self.bookplateleaf = bookplateleaf
      self.bookreaderDefaults = bookreaderDefaults
      self.boxid = boxid
      self.callNumber = callNumber
      self.camera = camera
      self.ccnum = ccnum
      self.closedCaptioning = closedCaptioning
      self.collection = collection
      self.collectionSize = collectionSize
      self.collectionsRaw = collectionsRaw
      self.color = color
      self.condition = condition
      self.conditionVisual = conditionVisual
      self.contributor = contributor
      self.coverage = coverage
      self.creator = creator
      self.creatorAltScript = creatorAltScript
      self.curation = curation
      self.date = date
      self.derivetorrents = derivetorrents
      self.description = description
      self.discs = discs
      self.downloads = downloads
      self.externalIdentifier = externalIdentifier
      self.filesCount = filesCount
      self.filesxml = filesxml
      self.firstfiledate = firstfiledate
      self.foldoutcount = foldoutcount
      self.format = format
      self.framesPerSecond = framesPerSecond
      self.genre = genre
      self.geoRestricted = geoRestricted
      self.hasMp3 = hasMp3
      self.hidden = hidden
      self.homepage = homepage
      self.identifierAccess = identifierAccess
      self.identifierArk = identifierArk
      self.identifierBib = identifierBib
      self.imagecount = imagecount
      self.indexdate = indexdate
      self.indexflag = indexflag
      self.invoice = invoice
      self.isbn = isbn
      self.isDark = isDark
      self.issn = issn
      self.itemCount = itemCount
      self.itemSize = itemSize
      self.language = language
      self.lastfiledate = lastfiledate
      self.lccn = lccn
      self.licenseurl = licenseurl
      self.limflag = limflag
      self.lineage = lineage
      self.md5s = md5s
      self.mediatype = mediatype
      self.month = month
      self.nextItem = nextItem
      self.noarchivetorrent = noarchivetorrent
      self.noindex = noindex
      self.notes = notes
      self.numericId = numericId
      self.numRecentReviews = numRecentReviews
      self.numReviews = numReviews
      self.numStaffPicks = numStaffPicks
      self.numTopBa = numTopBa
      self.numTopDl = numTopDl
      self.oaiUpdatedate = oaiUpdatedate
      self.oclcId = oclcId
      self.ocr = ocr
      self.ocrDetectedLang = ocrDetectedLang
      self.ocrDetectedLangConf = ocrDetectedLangConf
      self.ocrDetectedScript = ocrDetectedScript
      self.ocrDetectedScriptConf = ocrDetectedScriptConf
      self.ocrModuleVersion = ocrModuleVersion
      self.ocrParameters = ocrParameters
      self.openlibraryAuthor = openlibraryAuthor
      self.openlibraryEdition = openlibraryEdition
      self.openlibrarySubject = openlibrarySubject
      self.openlibraryWork = openlibraryWork
      self.`operator` = `operator`
      self.pageNumberConfidence = pageNumberConfidence
      self.pageNumberModuleVersion = pageNumberModuleVersion
      self.pageProgression = pageProgression
      self.pdfModuleVersion = pdfModuleVersion
      self.pick = pick
      self.possibleCopyrightStatus = possibleCopyrightStatus
      self.ppi = ppi
      self.previousItem = previousItem
      self.`public` = `public`
      self.publicdate = publicdate
      self.publicFormat = publicFormat
      self.publisher = publisher
      self.relatedCollection = relatedCollection
      self.relatedExternalId = relatedExternalId
      self.republisher = republisher
      self.republisherDate = republisherDate
      self.republisherOperator = republisherOperator
      self.republisherTime = republisherTime
      self.repubSeconds = repubSeconds
      self.repubState = repubState
      self.reviewdate = reviewdate
      self.rights = rights
      self.runtime = runtime
      self.scandate = scandate
      self.scanfee = scanfee
      self.scanner = scanner
      self.scanningcenter = scanningcenter
      self.shndiscs = shndiscs
      self.showRelatedMusicByTrack = showRelatedMusicByTrack
      self.showSearchByDate = showSearchByDate
      self.showSearchByYear = showSearchByYear
      self.size = size
      self.sortBy = sortBy
      self.sound = sound
      self.source = source
      self.sourcePixelHeight = sourcePixelHeight
      self.sourcePixelWidth = sourcePixelWidth
      self.sponsor = sponsor
      self.sponsordate = sponsordate
      self.spotlightIdentifier = spotlightIdentifier
      self.startLocaltime = startLocaltime
      self.startTime = startTime
      self.stopTime = stopTime
      self.strippedTags = strippedTags
      self.subject = subject
      self.summary = summary
      self.taper = taper
      self.tasks = tasks
      self.title = title
      self.titleAltScript = titleAltScript
      self.titleMessage = titleMessage
      self.transferer = transferer
      self.tuner = tuner
      self.type = type
      self.updated = updated
      self.updatedate = updatedate
      self.updater = updater
      self.uploader = uploader
      self.utcOffset = utcOffset
      self.venue = venue
      self.videoCodec = videoCodec
      self.volume = volume
      self.week = week
      self.year = year
    }
  }
}
