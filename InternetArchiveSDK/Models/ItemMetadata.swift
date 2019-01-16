//
//  ItemMetadata.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public struct ItemMetadata: Decodable {
    public let addeddate: ModelField<Date>?
    public let adder: ModelField<String>?
    public let avgRating: ModelField<Double>?
    public let backupLocation: ModelField<String>?
    public let collection: ModelField<String>?
    public let coverage: ModelField<String>?
    public let creator: ModelField<String>?
    public let curation: ModelField<String>?
    public var date: ModelField<Date>?
    public let description: ModelField<String>?
    public let downloads: ModelField<Int>?
    public let discs: ModelField<String>?
    public let format: ModelField<String>?
    public let hasMp3: ModelField<String>?
    public let hidden: ModelField<Bool>?
    public let homepage: ModelField<URL>?
    public let identifier: String
    public let indexdate: ModelField<Date>?
    public let indexflag: ModelField<String>?
    public let isDark: ModelField<String>?
    public let itemSize: ModelField<Int>?
    public let lineage: ModelField<String>?
    public let limflag: ModelField<String>?
    public let md5s: ModelField<String>?
    public let mediatype: ModelField<String>?
    public let month: ModelField<Int>?
    public let notes: ModelField<String>?
    public let numericId: ModelField<Int>?
    public let numRecentReviews: ModelField<Int>?
    public let numTopBa: ModelField<Int>?
    public let numTopDl: ModelField<Int>?
    public let oaiUpdatedate: ModelField<Date>?
    public let pick: ModelField<String>?
    public let `public`: ModelField<String>?
    public let publicdate: ModelField<Date>?
    public let publisher: ModelField<String>?
    public let reviewdate: ModelField<Date>?
    public let rights: ModelField<String>?
    public let runtime: ModelField<String>?
    public let shndiscs: ModelField<String>?
    public let showSearchByYear: ModelField<Bool>?
    public let showSearchByDate: ModelField<Bool>?
    public let source: ModelField<String>?
    public let spotlightIdentifier: ModelField<String>?
    public let subject: ModelField<String>?
    public let taper: ModelField<String>?
    public let tasks: ModelField<String>?
    public let title: ModelField<String>?
    public let transferer: ModelField<String>?
    public let type: ModelField<String>?
    public let updated: ModelField<String>?
    public let updatedate: ModelField<Date>?
    public let updater: ModelField<String>?
    public let uploader: ModelField<String>?
    public let venue: ModelField<String>?
    public let week: ModelField<Int>?
    public let year: ModelField<Int>?
  }
}
