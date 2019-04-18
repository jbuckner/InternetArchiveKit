//
//  InternetArchiveErrors.swift
//  InternetArchiveKit
//
//  Created by Jason Buckner on 11/13/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

extension InternetArchive {
  /**
   Errors that may be returned by the InternetArchive class
   */
  public enum InternetArchiveError: Error {
    case invalidUrl
    case noDataReturned
  }
}
