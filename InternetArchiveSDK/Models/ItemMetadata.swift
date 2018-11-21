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
    public let addeddate: String?
    public let adder: String?
    public let avgRating: DoubleField?
    public let backupLocation: String?
    public let collection: [String]?
    public let coverage: String?
    public let creator: String?
    public let curation: String?
    public var date: ISODateField?
    public let description: String?
    public let downloads: Int?
    public let discs: String?
    public let format: StringOrArrayField?
    public let hasMp3: String?
    public let identifier: String
    public let indexflag: [String]?
    public let isDark: String?
    public let itemSize: Int?
    public let lineage: String?
    public let md5s: String?
    public let mediatype: String?
    public let month: Int?
    public let notes: String?
    public let pick: String?
    public let `public`: String?
    public let publicdate: String?
    public let publisher: StringOrArrayField?
    public let runtime: String?
    public let shndiscs: String?
    public let source: String?
    public let subject: StringOrArrayField?
    public let taper: String?
    public let tasks: String?
    public let title: String?
    public let transferer: String?
    public let type: StringOrArrayField?
    public let updated: String?
    public let updatedate: StringOrArrayField?
    public let updater: StringOrArrayField?
    public let uploader: String?
    public let venue: String?
    public let week: Int?
    public let year: IntField?
  }
}

//extension InternetArchive.ItemMetadata: Decodable {
//  public init(from decoder: Decoder) throws {
//    let values = try decoder.container(keyedBy: CodingKeys.self)
//    addeddate = try values.decodeIfPresent(String.self, forKey: .addeddate)
//    adder = try values.decodeIfPresent(String.self, forKey: .adder)
//    backupLocation = try values.decodeIfPresent(String.self, forKey: .backupLocation)
//    collection = try values.decodeIfPresent([String].self, forKey: .collection)
//    coverage = try values.decodeIfPresent(String.self, forKey: .coverage)
//    creator = try values.decodeIfPresent(String.self, forKey: .creator)
//    curation = try values.decodeIfPresent(String.self, forKey: .curation)
//    _date = try values.decodeIfPresent(String.self, forKey: .date)
//    description = try values.decodeIfPresent(String.self, forKey: .description)
//    discs = try values.decodeIfPresent(String.self, forKey: .discs)
//    hasMp3 = try values.decodeIfPresent(String.self, forKey: .hasMp3)
//    identifier = try values.decode(String.self, forKey: .identifier)
//    isDark = try values.decodeIfPresent(String.self, forKey: .isDark)
//    lineage = try values.decodeIfPresent(String.self, forKey: .lineage)
//    md5s = try values.decodeIfPresent(String.self, forKey: .md5s)
//    mediatype = try values.decodeIfPresent(String.self, forKey: .mediatype)
//    notes = try values.decodeIfPresent(String.self, forKey: .notes)
//    pick = try values.decodeIfPresent(String.self, forKey: .pick)
//    `public` = try values.decodeIfPresent(String.self, forKey: .public)
//    publicdate = try values.decodeIfPresent(String.self, forKey: .publicdate)
//    publisher = try values.decodeIfPresent(InternetArchive.StringOrArray.self, forKey: .publisher)
//    runtime = try values.decodeIfPresent(String.self, forKey: .runtime)
//    shndiscs = try values.decodeIfPresent(String.self, forKey: .shndiscs)
//    source = try values.decodeIfPresent(String.self, forKey: .source)
//    subject = try values.decodeIfPresent(String.self, forKey: .subject)
//    taper = try values.decodeIfPresent(String.self, forKey: .taper)
//    tasks = try values.decodeIfPresent(String.self, forKey: .tasks)
//    title = try values.decodeIfPresent(String.self, forKey: .title)
//    transferer = try values.decodeIfPresent(String.self, forKey: .transferer)
//    type = try values.decodeIfPresent(InternetArchive.StringOrArray.self, forKey: .type)
//    updated = try values.decodeIfPresent(String.self, forKey: .updated)
//    updatedate = try values.decodeIfPresent(InternetArchive.StringOrArray.self, forKey: .updatedate)
//    updater = try values.decodeIfPresent(InternetArchive.StringOrArray.self, forKey: .updater)
//    uploader = try values.decodeIfPresent(String.self, forKey: .uploader)
//    venue = try values.decodeIfPresent(String.self, forKey: .venue)
//    year = try values.decodeIfPresent(String.self, forKey: .year)
//  }
//
//  enum CodingKeys: String, CodingKey {
//    case addeddate
//    case adder
//    case backupLocation
//    case collection
//    case coverage
//    case creator
//    case curation
//    case date
//    case description
//    case discs
//    case hasMp3
//    case identifier
//    case isDark
//    case lineage
//    case md5s
//    case mediatype
//    case notes
//    case pick
//    case `public`
//    case publicdate
//    case publisher
//    case runtime
//    case shndiscs
//    case source
//    case subject
//    case taper
//    case tasks
//    case title
//    case transferer
//    case type
//    case updated
//    case updatedate
//    case updater
//    case uploader
//    case venue
//    case year
//  }
//
//}
