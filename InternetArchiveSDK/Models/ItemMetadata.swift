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
    public let backupLocation: String?
    public let collection: [String]?
    public let coverage: String?
    public let creator: String?
    public let curation: String?
    public let date: String?
    public let description: String?
    public let discs: String?
    public let hasMp3: String?
    public let identifier: String
    public let isDark: String?
    public let lineage: String?
    public let md5s: String?
    public let mediatype: String?
    public let notes: String?
    public let pick: String?
    public let `public`: String?
    public let publicdate: String?
    public let publisher: StringOrArray?
    public let runtime: String?
    public let shndiscs: String?
    public let source: String?
    public let subject: String?
    public let taper: String?
    public let tasks: String?
    public let title: String?
    public let transferer: String?
    public let type: StringOrArray?
    public let updated: String?
    public let updatedate: StringOrArray?
    public let updater: StringOrArray?
    public let uploader: String?
    public let venue: String?
    public let year: String?
  }
}
