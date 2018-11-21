//
//  File.swift
//  InternetArchiveSDK
//
//  Created by Jason Buckner on 11/5/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  public struct File: Decodable {
    public let album: String?
    public let bitrate: IntField?
    public let crc32: String?
    public let creator: String?
    public let format: String?
    public let height: IntField?
    public let length: String?
    public let md5: String?
    public let mtime: String?
    public let name: String?
    public let original: StringOrArrayField?
    public let sha1: String?
    public let size: IntField?
    public let source: String?
    public let title: String?
    public let track: IntField?
    public let width: IntField?
  }
}

//"name": "gd73-06-10d1t02.mp3",
//"source": "derivative",
//"creator": "Grateful Dead",
//"title": "Beat It On Down The Line",
//"track": "2",
//"album": "1973-06-10 - Robert F. Kennedy Stadium",
//"bitrate": "197",
//"length": "02:14",
//"format": "VBR MP3",
//"original": "gd73-06-10d1t02.shn",
//"mtime": "1310166624",
//"size": "3331603",
//"md5": "cc67034a94cbd44a91b644ad2ab99e16",
//"crc32": "427de00b",
//"sha1": "c1f7279ccb1058c102607304d3e27b493ced0419",
//"height": "0",
//"width": "0"
