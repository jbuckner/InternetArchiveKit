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
  }
}
