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
    public let identifier: String
    public let collection: [String]?
    public let creator: String?
    public let updated: String?
    public let tasks: String?
    public let isDark: String?
    public let source: String?
    public let title: String?
    public let mediatype: String?
    public let description: String?
    public let type: String?
    public let date: String?
    public let year: String?
    public let publicdate: String?
    public let addeddate: String?
    public let uploader: String?
    public let venue: String?
    public let coverage: String?
    public let md5s: String?
    public let notes: String?
    public let updatedate: String?
    public let updater: String?
    public let backupLocation: String?
  }
}
