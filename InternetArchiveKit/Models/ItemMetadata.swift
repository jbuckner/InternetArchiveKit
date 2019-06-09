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

   See the Internet Archive's
   [Python API Reference](https://archive.org/services/docs/api/metadata-schema/index.html#metadata-schema)
   for a description of the properties.

   **Note**: This is not an exhaustive list of metadata properties. If you need some that are missing,
   please open a pull request.
   */
  public struct ItemMetadata: Decodable {
    public let addeddate: ModelField<IADate>?
    public let adder: ModelField<IAString>?
    public let avgRating: ModelField<IADouble>?
    public let backupLocation: ModelField<IAString>?
    public let collection: ModelField<IAString>?
    public let coverage: ModelField<IAString>?
    public let creator: ModelField<IAString>?
    public let curation: ModelField<IAString>?
    public var date: ModelField<IADate>?
    public let description: ModelField<IAString>?
    public let downloads: ModelField<IAInt>?
    public let discs: ModelField<IAString>?
    public let format: ModelField<IAString>?
    public let hasMp3: ModelField<IAString>?
    public let hidden: ModelField<IABool>?
    public let homepage: ModelField<IAURL>?
    public let identifier: String
    public let indexdate: ModelField<IADate>?
    public let indexflag: ModelField<IAString>?
    public let isDark: ModelField<IAString>?
    public let itemSize: ModelField<IAInt>?
    public let lineage: ModelField<IAString>?
    public let limflag: ModelField<IAString>?
    public let md5s: ModelField<IAString>?
    public let mediatype: ModelField<IAString>?
    public let month: ModelField<IAInt>?
    public let notes: ModelField<IAString>?
    public let numericId: ModelField<IAInt>?
    public let numRecentReviews: ModelField<IAInt>?
    public let numTopBa: ModelField<IAInt>?
    public let numTopDl: ModelField<IAInt>?
    public let oaiUpdatedate: ModelField<IADate>?
    public let pick: ModelField<IAString>?
    public let `public`: ModelField<IAString>?
    public let publicdate: ModelField<IADate>?
    public let publisher: ModelField<IAString>?
    public let reviewdate: ModelField<IADate>?
    public let rights: ModelField<IAString>?
    public let runtime: ModelField<IAString>?
    public let shndiscs: ModelField<IAString>?
    public let showSearchByYear: ModelField<IABool>?
    public let showSearchByDate: ModelField<IABool>?
    public let source: ModelField<IAString>?
    public let spotlightIdentifier: ModelField<IAString>?
    public let subject: ModelField<IAString>?
    public let taper: ModelField<IAString>?
    public let tasks: ModelField<IAString>?
    public let title: ModelField<IAString>?
    public let transferer: ModelField<IAString>?
    public let type: ModelField<IAString>?
    public let updated: ModelField<IAString>?
    public let updatedate: ModelField<IADate>?
    public let updater: ModelField<IAString>?
    public let uploader: ModelField<IAString>?
    public let venue: ModelField<IAString>?
    public let week: ModelField<IAInt>?
    public let year: ModelField<IAInt>?

    public init(addeddate: ModelField<IADate>?,
                adder: ModelField<IAString>?,
                avgRating: ModelField<IADouble>?,
                backupLocation: ModelField<IAString>?,
                collection: ModelField<IAString>?,
                coverage: ModelField<IAString>?,
                creator: ModelField<IAString>?,
                curation: ModelField<IAString>?,
                date: ModelField<IADate>?,
                description: ModelField<IAString>?,
                downloads: ModelField<IAInt>?,
                discs: ModelField<IAString>?,
                format: ModelField<IAString>?,
                hasMp3: ModelField<IAString>?,
                hidden: ModelField<IABool>?,
                homepage: ModelField<IAURL>?,
                identifier: String,
                indexdate: ModelField<IADate>?,
                indexflag: ModelField<IAString>?,
                isDark: ModelField<IAString>?,
                itemSize: ModelField<IAInt>?,
                lineage: ModelField<IAString>?,
                limflag: ModelField<IAString>?,
                md5s: ModelField<IAString>?,
                mediatype: ModelField<IAString>?,
                month: ModelField<IAInt>?,
                notes: ModelField<IAString>?,
                numericId: ModelField<IAInt>?,
                numRecentReviews: ModelField<IAInt>?,
                numTopBa: ModelField<IAInt>?,
                numTopDl: ModelField<IAInt>?,
                oaiUpdatedate: ModelField<IADate>?,
                pick: ModelField<IAString>?,
                `public`: ModelField<IAString>?,
                publicdate: ModelField<IADate>?,
                publisher: ModelField<IAString>?,
                reviewdate: ModelField<IADate>?,
                rights: ModelField<IAString>?,
                runtime: ModelField<IAString>?,
                shndiscs: ModelField<IAString>?,
                showSearchByYear: ModelField<IABool>?,
                showSearchByDate: ModelField<IABool>?,
                source: ModelField<IAString>?,
                spotlightIdentifier: ModelField<IAString>?,
                subject: ModelField<IAString>?,
                taper: ModelField<IAString>?,
                tasks: ModelField<IAString>?,
                title: ModelField<IAString>?,
                transferer: ModelField<IAString>?,
                type: ModelField<IAString>?,
                updated: ModelField<IAString>?,
                updatedate: ModelField<IADate>?,
                updater: ModelField<IAString>?,
                uploader: ModelField<IAString>?,
                venue: ModelField<IAString>?,
                week: ModelField<IAInt>?,
                year: ModelField<IAInt>?) {
      self.addeddate = addeddate
      self.adder = adder
      self.avgRating = avgRating
      self.backupLocation = backupLocation
      self.collection = collection
      self.coverage = coverage
      self.creator = creator
      self.curation = curation
      self.date = date
      self.description = description
      self.downloads = downloads
      self.discs = discs
      self.format = format
      self.hasMp3 = hasMp3
      self.hidden = hidden
      self.homepage = homepage
      self.identifier = identifier
      self.indexdate = indexdate
      self.indexflag = indexflag
      self.isDark = isDark
      self.itemSize = itemSize
      self.lineage = lineage
      self.limflag = limflag
      self.md5s = md5s
      self.mediatype = mediatype
      self.month = month
      self.notes = notes
      self.numericId = numericId
      self.numRecentReviews = numRecentReviews
      self.numTopBa = numTopBa
      self.numTopDl = numTopDl
      self.oaiUpdatedate = oaiUpdatedate
      self.pick = pick
      self.`public` = `public`
      self.publicdate = publicdate
      self.publisher = publisher
      self.reviewdate = reviewdate
      self.rights = rights
      self.runtime = runtime
      self.shndiscs = shndiscs
      self.showSearchByYear = showSearchByYear
      self.showSearchByDate = showSearchByDate
      self.source = source
      self.spotlightIdentifier = spotlightIdentifier
      self.subject = subject
      self.taper = taper
      self.tasks = tasks
      self.title = title
      self.transferer = transferer
      self.type = type
      self.updated = updated
      self.updatedate = updatedate
      self.updater = updater
      self.uploader = uploader
      self.venue = venue
      self.week = week
      self.year = year
    }
  }
}
