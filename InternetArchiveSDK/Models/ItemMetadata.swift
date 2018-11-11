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
    let identifier: String
    let collection: [String]?
    let creator: String?
    let updated: String?
    let tasks: String?
    let is_dark: String?
    let source: String?
    let title: String?
    let mediatype: String?
    let description: String?
    let type: String?
    let date: String?
    let year: String?
    let publicdate: String?
    let addeddate: String?
    let uploader: String?
    let venue: String?
    let coverage: String?
    let md5s: String?
    let notes: String?
    let updatedate: String?
    let updater: String?
    let backup_location: String?
  }
}
