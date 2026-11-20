//
//  ItemMetadata+Runtime.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 8/22/26.
//  Copyright © 2026 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive.ItemMetadata {
  /// `runtime` as a `TimeInterval`, or `nil` when it isn't written as one.
  ///
  /// Uploaders type this field by hand and the Archive doesn't normalize it, so alongside
  /// `"2:29:30"` and `"133:54"` you get `"245 Mins."`, `"2hr, 07min"` and `"3'19'58"`. That's
  /// why `runtime` stays a string: typing it as an interval outright would turn every
  /// free-form value into `nil` and lose it. Read `runtime` for what the uploader wrote, and
  /// this for a number when there is one.
  ///
  /// For a duration you can rely on, use a file's `length` instead, which the Archive
  /// derives itself.
  public var runtimeInterval: TimeInterval? {
    guard let string = runtime?.value else { return nil }
    return InternetArchive.IATimeInterval(fromString: string)?.value
  }
}
